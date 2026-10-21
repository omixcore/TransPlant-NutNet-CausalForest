"""Rebuild Figs 1 and 3–8 solely from versioned output CSVs/logs.

No forest is refitted here; Fig 8a displays observed dCTI, not unavailable CATEs.
Run: python rebuild_recorded_figures.py
"""
from pathlib import Path
import re
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm

OUT = Path(__file__).parent / 'output'
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':8,'axes.spines.top':False,
                     'axes.spines.right':False,'pdf.fonttype':42,'savefig.facecolor':'white'})
BLUE, RED, GREY = '#2C6E9B', '#B4462F', '#595959'

def save(fig,name):
    fig.savefig(OUT / (name+'.png'),dpi=300,bbox_inches='tight')
    fig.savefig(OUT / (name+'.pdf'),bbox_inches='tight')
    plt.close(fig)

def fig1():
    regions=pd.read_csv(OUT/'fig1_region_summary.csv')
    dat=pd.read_csv(OUT/'turf_year_cate_v3.csv')
    fig=plt.figure(figsize=(7.2,6.0),layout='constrained')
    gs=fig.add_gridspec(2,2,height_ratios=[1.7,1])
    ax=fig.add_subplot(gs[0,:])
    norm=TwoSlopeNorm(vmin=min(-4,regions.cate.min()),vcenter=0,vmax=max(4,regions.cate.max()))
    dots=ax.scatter(regions.lon,regions.lat,s=30+regions.n*.5,c=regions.cate,cmap='RdBu',norm=norm,
                    edgecolors='#333333',linewidths=.5,zorder=4)
    ax.set(xlim=(-125,115),ylim=(20,75),xlabel='Longitude (°E)',ylabel='Latitude (°N)',
           title=f'(a) Geographic distribution: {len(regions)} regions, 9 countries')
    ax.set_xticks([-100,-50,0,50,100]); ax.grid(color='#dddddd',linewidth=.5)
    fig.colorbar(dots,ax=ax,shrink=.75,label='Mean predicted richness effect (species)')
    ax.text(.01,.02,'Point size ∝ turf-years; coordinates from region summary',transform=ax.transAxes,
            fontsize=7,color=GREY)
    bx=fig.add_subplot(gs[1,0]); bx.set(xlim=(0,10),ylim=(0,10),title='(b) Transplant comparison')
    bx.plot([1,9],[8,2],color='#888888',lw=2)
    bx.scatter([1,9],[8,2],c=[BLUE,RED],s=80,zorder=3)
    bx.annotate('Downslope transplant',xy=(8,2.8),xytext=(2.5,7.5),
                arrowprops={'arrowstyle':'->','color':RED,'lw':1.6},color=RED,fontsize=8)
    bx.text(.5,8.5,'Cold source',fontsize=8); bx.text(6.1,.5,'Warm destination\nwith in-situ controls',fontsize=8)
    bx.set_axis_off()
    cx=fig.add_subplot(gs[1,1]); dose=dat.loc[dat.W_bin==1,'W_cont'].dropna()
    cx.hist(dose,bins=25,color=RED,edgecolor='white'); cx.axvline(dose.median(),color='#222',ls='--')
    cx.set(title='(c) Destination–source temperature',xlabel='Temperature difference (°C)',ylabel='Turf-years')
    cx.text(.97,.95,f'Median {dose.median():.1f} °C',ha='right',va='top',transform=cx.transAxes)
    save(fig,'fig1_study_system')

def fig6():
    dat=pd.read_csv(OUT/'nutnet_plot_cate.csv'); log=(OUT/'run_log_nutnet.txt').read_text()
    n,sites,treated=map(int,re.search(r'n=(\d+) sites=(\d+) treated=(\d+)',log).groups())
    vals=[tuple(map(float,re.search(pattern,log).groups())) for pattern in
          [r'ATE = ([\d.]+) g/m2 \(SE ([\d.]+)\)',r'P-only ATE = ([\d.]+) g/m2 \(SE ([\d.]+)\)']]
    assert len(dat[dat.trt.isin(['Ctrl','N','NP'])])==n and dat[dat.trt.isin(['N','NP'])].shape[0]==treated
    fig,axes=plt.subplots(1,2,figsize=(7.2,3.2),layout='constrained')
    a,b=axes
    for y,(name,(est,se)) in enumerate(zip(['N/NP versus control','P versus control'],vals)):
        a.errorbar(est,y,xerr=1.96*se,fmt='o',color='#3D6E4E',capsize=4)
    a.axvline(0,ls='--',color=GREY); a.set(yticks=[0,1],yticklabels=['N/NP versus control','P versus control'],
         xlabel='ATE on ANPP (g m⁻²)',title='(a) Fertilisation effects')
    a.invert_yaxis(); a.text(.02,-.23,f'{sites} sites; N/NP: {treated} treated, {n-treated} controls',
                            transform=a.transAxes,fontsize=7,clip_on=False)
    site=dat[dat.trt!='Ctrl'].groupby('site').CATE.mean().sort_values()
    b.scatter(site.values,range(len(site)),color='#3D6E4E'); b.axvline(vals[0][0],ls=':',color='#3D6E4E')
    b.set(yticks=range(len(site)),yticklabels=site.index,xlabel='Mean plot CATE (g m⁻²)',
          title='(b) Site predictions'); b.grid(axis='x',alpha=.2)
    save(fig,'fig6_nutnet')

def fig3():
    data=pd.read_csv(OUT/'turf_year_cate_v3.csv')
    fig,axes=plt.subplots(1,3,figsize=(8.4,2.8),layout='constrained')
    for ax,col,title,label in zip(axes[:2],['orig_temp','base_rich'],
        ['(a) Source temperature','(b) Baseline richness'],['Source temperature (°C)','Baseline species richness']):
        tab=data[[col,'CATE_rich']].copy(); tab['bin']=pd.qcut(tab[col].rank(method='first'),7,labels=False)
        means=tab.groupby('bin').agg(x=(col,'mean'),y=('CATE_rich','mean'))
        ax.plot(means.x,means.y,'o-',color=BLUE); ax.axhline(0,ls='--',color=GREY)
        ax.set(xlabel=label,ylabel='Mean predicted CATE (species)',title=title)
    ax=axes[2]; tab=data[['orig_temp','base_rich','CATE_rich']].copy()
    tab['tx']=pd.qcut(tab.orig_temp.rank(method='first'),12,labels=False)
    tab['rx']=pd.qcut(tab.base_rich.rank(method='first'),12,labels=False)
    cells=tab.groupby(['tx','rx']).agg(x=('orig_temp','mean'),y=('base_rich','mean'),
                                       cate=('CATE_rich','mean'),n=('CATE_rich','size')).query('n >= 4')
    sc=ax.scatter(cells.x,cells.y,c=cells.cate,s=8+cells.n*3,cmap='RdBu',vmin=-2,vmax=2,
                  edgecolor='#555',linewidth=.3)
    ax.set(xlabel='Source temperature (°C)',ylabel='Baseline richness',
           title='(c) Observed covariate cells')
    fig.colorbar(sc,ax=ax,label='Mean predicted CATE')
    save(fig,'fig3_who_benefits')

def fig4():
    log=(OUT/'run_log_event.txt').read_text()
    pattern=r'^([A-Z]{2}_[A-Za-z0-9]+)\s+n=\s*(\d+) turfs=\s*(\d+) ATE=([+-]?[\d.]+) \(SE ([\d.]+)\)'
    rows=re.findall(pattern,log,re.MULTILINE)
    assert len(rows)==6, 'Expected six subgroup estimates in run_log_event.txt'
    data=pd.DataFrame(rows,columns=['Region','n','turfs','ate','se'])
    for col in ['n','turfs','ate','se']: data[col]=pd.to_numeric(data[col])
    data['lo']=data.ate-1.96*data.se;data['hi']=data.ate+1.96*data.se
    data.to_csv(OUT/'fig4_region_ate.csv',index=False)
    data=data.sort_values('ate')
    fig,ax=plt.subplots(figsize=(7.2,3.5),layout='constrained')
    for y,r in enumerate(data.itertuples(index=False)):
        ax.errorbar(r.ate,y,xerr=[[r.ate-r.lo],[r.hi-r.ate]],fmt='none',color=BLUE,capsize=3)
        ax.scatter(r.ate,y,s=16+1.7*r.turfs,color=BLUE,zorder=3)
    ax.axvline(0,color=GREY,ls='--');ax.set(yticks=range(len(data)),yticklabels=data.Region,
        xlabel='Region-specific ATE on richness (species)',title='Regional point estimates and 95% intervals')
    save(fig,'fig4_region_ate')

def fig5():
    data=pd.read_csv(OUT/'turf_year_cate_v3.csv')
    data['ys']=data.Year-data.base_year
    event=data[data.ys>=1].groupby('ys').CATE_rich.agg(['mean','size']).query('size >= 20')
    log=(OUT/'run_log_event.txt').read_text()
    rows=re.findall(r'^(year (?:1|2|>= 3))\s+n=\s*(\d+)\s+ATE=([+-]?[\d.]+)\s+SE=([\d.]+)\s+95%CI=\[([+-]?[\d.]+),\s*([+-]?[\d.]+)\]',log,re.MULTILINE)
    assert len(rows)==3, 'Expected three phase estimates in run_log_event.txt'
    ph=pd.DataFrame(rows,columns=['phase','n','ate','se','lo','hi'])
    for col in ['n','ate','se','lo','hi']: ph[col]=pd.to_numeric(ph[col])
    ph['phase']=ph.phase.str.replace('year','Year',regex=False)
    ph.to_csv(OUT/'fig5_phase_ate.csv',index=False)
    fig,axes=plt.subplots(1,2,figsize=(7.2,3),layout='constrained');a,b=axes
    a.plot(event.index,event['mean'],'o-',color=BLUE);a.axhline(0,ls='--',color=GREY)
    a.set(xlabel='Years since transplant',ylabel='Mean predicted CATE (species)',
          title='(a) Post-treatment predictions')
    for y,r in enumerate(ph.itertuples(index=False)):
        b.errorbar(r.ate,y,xerr=[[r.ate-r.lo],[r.hi-r.ate]],fmt='o',color=BLUE,capsize=3)
        b.text(r.hi+.15,y,f'n={r.n}',va='center',fontsize=7)
    b.axvline(0,ls='--',color=GREY);b.set(yticks=range(len(ph)),yticklabels=ph.phase,
        xlim=(min(-4,ph.lo.min()-.4),max(4,ph.hi.max()+1)),xlabel='ATE (species)',
        title='(b) Separate phase estimates');b.invert_yaxis()
    save(fig,'fig5_event_time')

def fig7():
    ate=pd.read_csv(OUT/'gainloss_ate.csv'); ph=pd.read_csv(OUT/'gainloss_turnover_phase.csv'); pan=pd.read_csv(OUT/'gainloss_panel.csv')
    assert len(pan)==1171
    fig=plt.figure(figsize=(7.2,6.3),layout='constrained'); gs=fig.add_gridspec(2,2)
    a=fig.add_subplot(gs[0,0]); b=fig.add_subplot(gs[0,1]); c=fig.add_subplot(gs[1,:])
    net=(.65,-.39,1.69)
    labels=['Colonisations','Extinctions','Total turnover','Net richness']
    for y,row in enumerate(ate.itertuples(index=False)):
        assert row.outcome==['colonisations','extinctions','turnover'][y]
        a.errorbar(row.est,y,xerr=[[row.est-row.lo],[row.hi-row.est]],fmt='o',color=BLUE,capsize=3)
        a.text(3.5,y,f'{row.est:+.2f} [{row.lo:.2f}, {row.hi:.2f}]',fontsize=7,va='center')
    a.errorbar(net[0],3,xerr=[[net[0]-net[1]],[net[2]-net[0]]],fmt='o',color=GREY,capsize=3)
    a.text(3.5,3,'+0.65 [−0.39, 1.69]',fontsize=7,va='center')
    a.axvline(0,ls='--',color=GREY); a.set(yticks=range(4),yticklabels=labels,xlim=(-1.4,6.5),
        xlabel='ATE (species per turf-year)',title='(a) Component estimates'); a.invert_yaxis()
    phase=ph[ph.phase.isin(['year 1','year 2','year >= 3'])]
    x=np.arange(3)
    b.errorbar(x,phase.est,yerr=[phase.est-phase.lo,phase.hi-phase.est],fmt='o-',color=BLUE,capsize=4)
    b.axhline(0,ls='--',color=GREY); b.set(xticks=x,xticklabels=['1','2','≥ 3'],ylim=(-3.4,5.3),
        xlabel='Years since transplant',ylabel='ATE on turnover',title='(b) Separate phase estimates')
    for i,row in enumerate(phase.itertuples(index=False)):
        b.text(i,-2.9,f'n={row.n}',ha='center',fontsize=7)
    for t,color,label in [(0,GREY,'In-situ control'),(1,RED,'Transplanted warm')]:
        subset=pan[pan.W_bin==t]
        c.scatter(subset.gains,subset.losses,s=9,alpha=.25,color=color,label=label,rasterized=True)
    lim=max(pan.gains.max(),pan.losses.max())+1
    c.plot([0,lim],[0,lim],'--',color=GREY,lw=.8)
    c.set(xlim=(-1,lim),ylim=(-1,lim),xlabel='Colonisations per turf-year',ylabel='Extinctions per turf-year',
        title='(c) Observed component counts'); c.legend(loc='upper left',frameon=False,ncol=2,fontsize=7)
    save(fig,'fig7_turnover')

def fig8():
    pan=pd.read_csv(OUT/'cti_panel.csv'); ate=pd.read_csv(OUT/'cti_ate.csv'); ph=pd.read_csv(OUT/'cti_phase.csv')
    tr=pd.read_csv(OUT/'cti_tracking.csv').iloc[0]
    row=ate[ate.outcome=='dCTI_degC'].iloc[0]
    fig,axes=plt.subplots(2,2,figsize=(7.2,6.2),layout='constrained'); a,b,c,d=axes.flat
    observed=pan.d_cti_ok.dropna(); a.hist(observed,bins=35,color=BLUE,edgecolor='white')
    a.axvline(0,color=GREY,ls='--'); a.set(xlabel='Observed ΔCTI (°C)',ylabel='Turf-years',
        title='(a) Observed CTI change (descriptive)')
    phase=ph[ph.phase.isin(['year 1','year 2','year >= 3'])]; xs=np.arange(3)
    b.bar(xs,phase.est,color=['#bbbbbb','#bbbbbb',RED],width=.55)
    b.errorbar(xs,phase.est,yerr=[phase.est-phase.lo,phase.hi-phase.est],fmt='none',color='#222',capsize=4)
    b.axhline(0,ls='--',color=GREY); b.set(xticks=xs,xticklabels=['1','2','≥ 3'],ylim=(-.09,.25),
        xlabel='Years since transplant',ylabel='ATE on ΔCTI (°C)',title='(b) Phase-specific estimates')
    for x,r in enumerate(phase.itertuples(index=False)):
        b.text(x,-.078,f'n={r.n}',ha='center',fontsize=7)
    groups=[pan.loc[(pan.W_bin==w)&pan.d_stp.notna(),'d_stp'].values for w in (0,1)]
    c.boxplot(groups,tick_labels=['In-situ','Warm'],showfliers=False,patch_artist=True,
              boxprops={'facecolor':'#bbd6e6'},medianprops={'color':RED})
    c.axhline(0,ls='--',color=GREY); c.set(ylabel='Coloniser STP − extinct STP (°C)',
        title='(c) Observed turnover direction (descriptive)')
    ratio=100*row.est/tr.dose_degC; lo=100*row.lo/tr.dose_degC; hi=100*row.hi/tr.dose_degC
    d.bar([0,1],[100,ratio],color=['#aaaaaa',RED],width=.5)
    d.errorbar([1],[ratio],yerr=[[ratio-lo],[hi-ratio]],fmt='none',color='#222',capsize=4)
    d.set(xticks=[0,1],xticklabels=['Mean imposed\nshift','Estimated CTI\nresponse'],ylim=(-5,115),
          ylabel='Fraction of temperature difference (%)',title='(d) CTI shift relative to dose')
    d.text(1,12,f'{ratio:.1f}% [{lo:.3f}, {hi:.1f}]',ha='center',fontsize=8)
    d.text(.01,-.23,'Approximate CI: fixed mean dose; BH p = 0.139',
           transform=d.transAxes,fontsize=6.7,clip_on=False)
    save(fig,'fig8_thermal_directionality')

if __name__=='__main__':
    fig1();fig3();fig4();fig5();fig6();fig7();fig8()
    print('Rebuilt figures 1 and 3–8 from recorded outputs')
