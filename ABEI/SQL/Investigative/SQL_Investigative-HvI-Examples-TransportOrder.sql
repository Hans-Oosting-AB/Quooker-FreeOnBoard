SELECT	oh.ordernr
		, oh.ord_soort
		, ol.*
FROM	orkrg oh (nolock)
		inner join dbo.orsrg as ol (nolock) on oh.ordernr = ol.ordernr 
where	1=1
		and oh.ord_soort = 'B'
--		and oh.ordernr = '   50035'

select	TOP 100
		gm.bkstnr_sub
		, gm.bkstnr
		, gm.artcode
		, gm.aantal
		, gm.bdr_hfl
		, gm.reknr
		, gm.transtype
		, gm.transsubtype
		, gm.warehouse
		, gm.LinkedLine
		, oh.levwijze
		, gm.datum
		, ol.*

from	dbo.orkrg as oh (nolock)
		inner join dbo.gbkmut as gm (nolock) on oh.ordernr = gm.bkstnr_sub
		inner join dbo.items as it (nolock) on gm.artcode = it.ItemCode	and gm.reknr = it.GLAccountDistribution
		inner join dbo.orsrg as ol (nolock) on ol.sysguid = gm.LinkedLine
where	1=1
		and oh.ord_soort = 'B'
--		and gm.bkstnr_sub = '90054986' --   50035'
		and gm.transtype = 'N'
		and gm.transsubtype = 'A'
		and gm.warehouse = '03'--'99'
		and oh.selcode = 'tr'
ORDER BY gm.datum DESC

select *
from ordlev

select it.itemcode, lev_crdnr, *
from items as it (nolock)
where 1=1
	and exists (select 1 from ordlev where levwijze = it.itemcode and it.type = 'P')

select *
from DDTests 
where Tablename = 'gbkmut'