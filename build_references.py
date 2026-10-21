## Build a cleaned, Crossref-verified reference list (GCB author-year style).
import json, time, urllib.parse, urllib.request, difflib, re, sys

TITLES = [
 "Lags in the response of mountain plant communities to climate change",
 "Accelerated increase in plant species richness on mountain summits is linked to warming",
 "Recent plant diversity changes on Europe's mountain summits",
 "Continent-wide response of mountain vegetation to climate change",
 "Elevation-dependent warming in mountain regions of the world",
 "Extinction debt of high-mountain plants under twenty-first-century climate change",
 "Climate-related range shifts a global multidimensional synthesis and new research directions",
 "Changes in plant community composition lag behind climate warming in lowland forests",
 "Range dynamics of mountain plants decrease with elevation",
 "Global buffering of temperatures under forest canopies",
 "Forest microclimate dynamics drive plant responses to warming",
 "Microclimate moderates plant responses to macroclimate warming",
 "Responses of tundra plants to experimental warming meta-analysis of the international tundra experiment",
 "Plant community responses to experimental warming across the tundra biome",
 "Plot-scale evidence of tundra vegetation change and links to recent summer warming",
 "Global assessment of experimental climate warming on tundra vegetation heterogeneity over space and time",
 "Experiment, monitoring, and gradient methods used to infer climate change effects on plant communities yield consistent patterns",
 "Warming experiments underpredict plant phenological responses to climate change",
 "Simulated climate change altered dominance hierarchies and diversity of an alpine biodiversity hotspot",
 "Novel competitors shape species responses to climate change",
 "A synthesis of transplant experiments and ecological niche models suggests that range limits are often niche limits",
 "Are species range limits simply niche limits writ large a review of transplant experiments",
 "A quantitative survey of local adaptation and fitness trade-offs",
 "A globally coherent fingerprint of climate change impacts across natural systems",
 "Ecological responses to recent climate change",
 "Rapid range shifts of species associated with high levels of climate warming",
 "European phenological response to climate change matches the warming pattern",
 "Global change and species interactions in terrestrial ecosystems",
 "Climate change and the past present and future of biotic interactions",
 "Assemblage time series reveal biodiversity change but not systematic loss",
 "BioTIME a database of biodiversity time series for the Anthropocene",
 "Biodiversity change is uncoupled from species richness trends consequences for conservation and monitoring",
 "Global meta-analysis reveals no net change in local-scale plant biodiversity over time",
 "The geography of biodiversity change in marine and terrestrial assemblages",
 "Species invasions exceed extinctions on islands worldwide a comparative study of plants and birds",
 "The importance of niches for the maintenance of species diversity",
 "The invasion paradox reconciling pattern and process in species invasions",
 "Productivity is a poor predictor of plant species richness",
 "Integrative modelling reveals mechanisms linking productivity and plant species richness",
 "Biodiversity loss and its impact on humanity",
 "Addition of multiple limiting resources reduces grassland diversity",
 "Grassland productivity limited by multiple nutrients",
 "Finding generality in ecology a model for globally distributed experiments",
 "General destabilizing effects of eutrophication on grassland productivity at multiple spatial scales",
 "Herbivores and nutrients control grassland plant diversity via light limitation",
 "TRY plant trait database enhanced coverage and open access",
 "The worldwide leaf economics spectrum",
 "Rebuilding community ecology from functional traits",
 "WorldClim 2 new 1-km spatial resolution climate surfaces for global land areas",
 "SoilGrids250m global gridded soil information based on machine learning",
 "Generalized random forests",
 "Estimation and inference of heterogeneous treatment effects using random forests",
 "Quasi-oracle estimation of heterogeneous treatment effects",
 "Double/debiased machine learning for treatment and structural parameters",
 "Dealing with limited overlap in estimation of average treatment effects",
 "Large sample properties of matching estimators for average treatment effects",
 "The central role of the propensity score in observational studies for causal effects",
 "The state of applied econometrics causality and policy evaluation",
 "Metalearners for estimating heterogeneous treatment effects using machine learning",
 "Random forests",
 "Estimating treatment effect heterogeneity in randomized program evaluation",
 "Causal assumptions and causal inference in ecological experiments",
 "Causal inference in coupled human and natural systems",
 "Causal analysis in control-impact ecological studies with observational data",
]

BAD = ("faculty opinions", "comment on", "reply to", "correction to", "erratum",
       "peer review", "recommendation of")
BADTYPE = {"component", "peer-review", "grant", "dataset", "posted-content"}

def initials(g):
    return "".join(p[0].upper() + "." for p in g.replace(".", " ").split() if p)

def fmt_authors(auths):
    if not auths:
        return None
    n = []
    for a in auths[:6]:
        fam = a.get("family") or a.get("name", "")
        giv = a.get("given", "")
        n.append(f"{fam}, {initials(giv)}" if giv else fam)
    s = n[0] if len(n) == 1 else ", ".join(n[:-1]) + " & " + n[-1]
    return s + ", et al." if len(auths) > 6 else s

def query(title, field="query.bibliographic"):
    q = urllib.parse.quote(title)
    url = ("https://api.crossref.org/works?" + field + "=" + q + "&rows=8"
           "&select=title,author,container-title,volume,page,issued,DOI,type,article-number")
    req = urllib.request.Request(url, headers={"User-Agent": "refcheck/2.0 (mailto:1264284076@qq.com)"})
    return json.load(urllib.request.urlopen(req, timeout=30))["message"]["items"]

def sentence(title):
    t = title.strip().rstrip(".")
    if t.isupper() or (sum(1 for c in t if c.isalpha() and c.isupper()) /
                       max(1, sum(1 for c in t if c.isalpha())) > 0.7):
        t = t.capitalize()
        # restore common proper nouns
        for w in ["African", "Europe", "European", "Island", "Islands", "Tundra", "Nutrient",
                  "Network", "Arctic", "Alpine", "Amazon", "Earth"]:
            t = re.sub(r"\b" + w.lower() + r"\b", w, t)
    return t

def clean_journal(j):
    return (j or "").replace("&amp;", "&").rstrip(".")

rows, missed = [], []
for t in TITLES:
    items = []
    for field in ("query.bibliographic", "query.title"):
        try:
            items = query(t, field)
        except Exception:
            items = []
        if items:
            break
        time.sleep(0.3)
    cands = []
    for it in items:
        cand = (it.get("title") or [""])[0]
        if not cand or it.get("type") in BADTYPE:
            continue
        if any(b in cand.lower() for b in BAD):
            continue
        sc = difflib.SequenceMatcher(None, t.lower(), cand.lower()).ratio()
        if sc >= 0.80:
            cands.append((sc, it))
    if not cands:
        missed.append(t)
        continue
    cands.sort(key=lambda x: (-x[0], 0 if x[1].get("volume") else 1))
    sc, best = cands[0]
    yr = (best.get("issued", {}).get("date-parts") or [[None]])[0][0]
    page = best.get("page") or best.get("article-number") or ""
    rows.append({"q": t, "title": sentence((best.get("title") or [""])[0]),
                 "authors": fmt_authors(best.get("author")), "year": yr,
                 "journal": clean_journal((best.get("container-title") or [""])[0]),
                 "volume": best.get("volume", ""), "page": page,
                 "doi": best.get("DOI", ""), "score": round(sc, 2)})
    time.sleep(0.3)

json.dump(rows, open("project/output/references.json", "w", encoding="utf-8"),
          ensure_ascii=False, indent=1)
print(f"matched {len(rows)}/{len(TITLES)}")
for m in missed:
    print("MISS:", m)
print("\n--- entries needing manual attention ---")
for r in rows:
    flags = []
    if not r["authors"]: flags.append("no-authors")
    if not r["year"]: flags.append("no-year")
    if not r["volume"]: flags.append("no-volume")
    if not r["page"]: flags.append("no-page")
    if not r["journal"]: flags.append("no-journal")
    if r["score"] < 0.9: flags.append(f"lowscore{r['score']}")
    if flags:
        print(f"{r['authors']} ({r['year']}) {r['title'][:60]} | {r['journal'][:30]} | {','.join(flags)}")
