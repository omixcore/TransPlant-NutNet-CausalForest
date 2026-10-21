## Final assembly: Crossref results + manual overrides + hand-entered classics.
import json, re

rows = json.load(open("project/output/references.json", encoding="utf-8"))

DROP = {"Pouresmaeily, M.", "Simonek, C. & de Franco, C.", "Genuer, R. & Poggi, J."}
rows = [r for r in rows if r["authors"] not in DROP]

# corrections keyed by first author surname + title fragment
FIX = {
 "Alexander, J.M., Chalmandrier": dict(year=2018),
 "Borer, E.T., Harpole":         dict(year=2014),
 "Elmendorf, S.C., Henry, G.H.R., Hollister, R.D., Fosaa": dict(year=2015),
 "Ferraro, P.J.":                dict(year=2019),
 "Hillebrand, H.":               dict(year=2018),
 "Lenoir, J. & Svenning":        dict(year=2015, authors="Lenoir, J. & Svenning, J.-C."),
 "Nie, X. & Wager":              dict(year=2021),
 "MCGILL, B.":                   dict(authors="McGill, B., Enquist, B., Weiher, E. & Westoby, M."),
 "MENZEL, A.":                   dict(authors="Menzel, A., Sparks, T.H., Estrella, N., Koch, E., Aasa, A. & Ahas, R., et al."),
 "ROSENBAUM, P.R.":              dict(authors="Rosenbaum, P.R. & Rubin, D.B."),
 "Sax, Gaines & Brown":          dict(authors="Sax, D.F., Gaines, S.D. & Brown, J.H.", page="766-783"),
 "Arft, A.M.":                   dict(page="491-512"),
 "Fick, S.E.":                   dict(title="WorldClim 2: new 1-km spatial resolution climate surfaces for global land areas"),
}
for r in rows:
    for k, v in FIX.items():
        if r["authors"].startswith(k):
            r.update(v)

# hand-entered classics / books / software / datasets (DOIs verified separately)
MANUAL = [
 ("Breiman, L.", 2001, "Random forests", "Machine Learning", "45", "5-32"),
 ("Steinbauer, M.J., Grytnes, J.-A., Jurasinski, G., Kulonen, A., Lenoir, J. & Pauli, H., et al.", 2018,
  "Accelerated increase in plant species richness on mountain summits is linked to warming", "Nature", "556", "231-234"),
 ("Pauli, H., Gottfried, M., Dullinger, S., Abdaladze, O., Akhalkatsi, M. & Alonso, J.L.B., et al.", 2012,
  "Recent plant diversity changes on Europe's mountain summits", "Science", "336", "353-355"),
 ("Zellweger, F., De Frenne, P., Lenoir, J., Vangansbeke, P., Verheyen, K. & Bernhardt-Römermann, M., et al.", 2020,
  "Forest microclimate dynamics drive plant responses to warming", "Science", "368", "772-775"),
 ("Walker, M.D., Wahren, C.H., Hollister, R.D., Henry, G.H.R., Ahlquist, L.E. & Alatalo, J.M., et al.", 2006,
  "Plant community responses to experimental warming across the tundra biome",
  "Proceedings of the National Academy of Sciences USA", "103", "1342-1346"),
 ("Elmendorf, S.C., Henry, G.H.R., Hollister, R.D., Björk, R.G., Boulanger-Lapointe, N. & Cooper, E.J., et al.", 2012,
  "Global assessment of experimental climate warming on tundra vegetation: heterogeneity over space and time",
  "Ecology Letters", "15", "164-175"),
 ("Dornelas, M., Antão, L.H., Moyes, F., Bates, A.E., Magurran, A.E. & Adam, D., et al.", 2018,
  "BioTIME: a database of biodiversity time series for the Anthropocene",
  "Global Ecology and Biogeography", "27", "760-786"),
 ("Blowes, S.A., Supp, S.R., Antão, L.H., Bates, A., Bruelheide, H. & Chase, J.M., et al.", 2019,
  "The geography of biodiversity change in marine and terrestrial assemblages", "Science", "366", "339-345"),
 ("Adler, P.B., Seabloom, E.W., Borer, E.T., Hillebrand, H., Hautier, Y. & Hector, A., et al.", 2011,
  "Productivity is a poor predictor of plant species richness", "Science", "333", "1750-1753"),
 ("Fay, P.A., Prober, S.M., Harpole, W.S., Knops, J.M.H., Bakker, J.D. & Borer, E.T., et al.", 2015,
  "Grassland productivity limited by multiple nutrients", "Nature Plants", "1", "15080"),
 ("Hautier, Y., Zhang, P., Loreau, M., Wilcox, K.R., Seabloom, E.W. & Borer, E.T., et al.", 2020,
  "General destabilizing effects of eutrophication on grassland productivity at multiple spatial scales",
  "Nature Communications", "11", "5375"),
 ("Borer, E.T., Seabloom, E.W., Gruner, D.S., Harpole, W.S., Hillebrand, H. & Lind, E.M., et al.", 2014,
  "Herbivores and nutrients control grassland plant diversity via light limitation", "Nature", "508", "517-520"),
 ("Kattge, J., Bönisch, G., Díaz, S., Lavorel, S., Prentice, I.C. & Leadley, P., et al.", 2020,
  "TRY plant trait database - enhanced coverage and open access", "Global Change Biology", "26", "119-188"),
 ("Wright, I.J., Reich, P.B., Westoby, M., Ackerly, D.D., Baruch, Z. & Bongers, F., et al.", 2004,
  "The worldwide leaf economics spectrum", "Nature", "428", "821-827"),
 ("Walther, G.-R., Post, E., Convey, P., Menzel, A., Parmesan, C. & Beebee, T.J.C., et al.", 2002,
  "Ecological responses to recent climate change", "Nature", "416", "389-395"),
]
for a, y, t, j, v, p in MANUAL:
    rows.append({"q": "", "title": t, "authors": a, "year": y, "journal": j,
                 "volume": v, "page": p, "doi": "", "score": 1.0})

# ---- format ----
def fmt(r):
    j = r["journal"].rstrip(".")
    tail = ""
    if r["volume"]:
        tail = f", {r['volume']}"
        if r["page"]:
            tail += ", " + r["page"].replace("-", "–")
    return (f"{r['authors']} ({r['year']}) {r['title'].rstrip('.')}. "
            f"*{j}*{tail}." if j else
            f"{r['authors']} ({r['year']}) {r['title'].rstrip('.')}.")

body = [fmt(r) for r in rows]

EXTRA = [
 "TransPlant Network (2024) TransPlant: a coordinated network of community transplant experiments along elevation gradients. Dataset, Open Science Framework. https://doi.org/10.17605/OSF.IO/9874T",
 "Borer, E.T., Seabloom, E.W., et al. (2020) Nutrient Network fertilization experiment synthesis. Environmental Data Initiative, knb-lter-cdr.692.1. https://doi.org/10.6073/pasta/7f984c2ed9e63754577ee711e6d74a6e",
 "Seabloom, E.W., Borer, E.T., Wilcox, K.R., et al. (2020) Effects of chronic nutrient enrichment on plant diversity and ecosystem productivity, 2008–2019. Environmental Data Initiative, edi.599.1. https://doi.org/10.6073/pasta/d78e6e48df246a03129c85a6c1da00d6",
 "MacArthur, R.H. & Wilson, E.O. (1967) *The Theory of Island Biogeography*. Princeton University Press, Princeton.",
 "Imbens, G.W. & Rubin, D.B. (2015) *Causal Inference for Statistics, Social, and Biomedical Sciences: An Introduction*. Cambridge University Press, Cambridge.",
 "R Core Team (2026) *R: A Language and Environment for Statistical Computing*. R Foundation for Statistical Computing, Vienna.",
 "Tibshirani, J., Athey, S., Sverdrup, E. & Wager, S. (2024) *grf: Generalized Random Forests*. R package version 2.6.1.",
]
allrefs = sorted(body + EXTRA, key=lambda s: s.lower())
open("project/output/references_formatted.md", "w", encoding="utf-8").write("\n\n".join(allrefs))
print("TOTAL", len(allrefs))
