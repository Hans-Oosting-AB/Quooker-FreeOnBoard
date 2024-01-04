/*
-- Check Order Creation

--UPDATE iPOr  SET
SELECT *,
    --rowstatus = CASE WHEN ISNULL(EntR.rowstatus,-1) = 2 THEN 2 ELSE iPOr.rowstatus END    -- ONLY SET Success
    --, [retry_counter]= CASE WHEN ISNULL(EntR.rowstatus,-1) <> 2 THEN iPOr.[retry_counter] + 1 ELSE iPOr.[retry_counter] END
    ----, seqno = CASE WHEN ISNULL(EntR.rowstatus,-1) <> 2 THEN seqno ELSE %seqno% END
    [sysmessage] = CASE ISNULL(EntR.rowstatus,-1) 
		WHEN 2 THEN 'Transport Order Created'
		ELSE ISNULL(EntR.errormessage, 'No result for Order found')
		END
    , sysmodified = CURRENT_TIMESTAMP
    , [transportOrderNr] = ISNULL(iPOr.[transportOrderNr], EntR.NewKeyvalue) -- SHOULD FAIL When iPOr.[transportOrderNr] IS NOT NULL
--    , [transportOrderLineId] = ISNULL(iPOr.[transportOrderLineId], EntR.NewKeyvalue) -- SHOULD FAIL When iPOr.[transportOrderLineId] IS NOT NULL
FROM [ABSC].[dbo].[_AB_tb_FBO_W99_Initial_PurchaseOrder_Receipts]  as iPOr WITH (ROWLOCK, NOWAIT)
    -- New ordernr
    LEFT OUTER JOIN [ABEI].dbo._AB_Entity_results EntR with (nolock) 
    ON 1=1 -- '%runid%' = rh.runid --Explicitely this run only
        and EntR.jobid = 1331 -- %jobid%
        and EntR.Entity = 'PurchaseOrderHeader'
        and EntR.Action = 'create'
        and EntR.ReferenceValue =  iPOr.[bkstnr]
WHERE 1=1
	AND iPOr.rowstatus = 1 -- being processed
	AND EntR.ID IS NOT NULL
	--AND o.runid = '%runid%'
--ORDER BY EntR.RunId

-- Check Order Line Creation
--UPDATE iPOr  SET
SELECT *,
    [sysmessage] = 
		CASE ISNULL(EntR.rowstatus,-1) 
		WHEN 2 THEN 'Transport Order & Order Line Created'
		ELSE 
			CASE WHEN iPOr.[sysmessage]  IS NULL 
				THEN ISNULL(EntR.errormessage, 'No result for Order Line found')
				ELSE ISNULL(EntR.errormessage, 'No result for Order Line found') + CHAR(13) + CHAR(10) 
					+ iPOr.[sysmessage] 
			END 
		END
	, sysmodified = CURRENT_TIMESTAMP
    , [transportOrderLineId] = ISNULL(iPOr.[transportOrderLineId], ol.ID) -- SHOULD FAIL When iPOr.[transportOrderLineId] IS NOT NULL
FROM [ABSC].[dbo].[_AB_tb_FBO_W99_Initial_PurchaseOrder_Receipts]  as iPOr WITH (ROWLOCK, NOWAIT)
    -- Results for lines
    LEFT OUTER JOIN [ABEI].dbo._AB_Entity_results EntR with (nolock) 
        ON 1=1 --'%runid%' = r.runid --Explicitely this run only
        and EntR.jobid = 1331 -- %jobid%
        and EntR.Entity = 'PurchaseOrderLine'
        and EntR.Action = 'create'
        and EntR.ReferenceValue = iPOr.[orderLineID]
	LEFT OUTER JOIN [115].dbo.AdditionalOrderLines as olt WITH (NOLOCK)
		ON STR(iPOr.[orderLineID]) = olt.Field02
	LEFT OUTER JOIN [115].[dbo].[orsrg] as ol WITH (NOLOCK)
		ON olt.OrderNumber = ol.ordernr
		AND olt.LineNumber = ol.regel
WHERE 1=1
	AND iPOr.rowstatus = 1 -- being processed
	AND iPOr.transportOrderNr IS NOT NULL -- Transport Order has been listed


-- LIST Success

--UPDATE iPOr  SET
SELECT *,
    runid = '%runid%'
	, rowstatus = 2
 --   , [retry_counter]= CASE WHEN ISNULL(EntR.rowstatus,-1) <> 2 THEN iPOr.[retry_counter] + 1 ELSE iPOr.[retry_counter] END
 	, sysmodified = CURRENT_TIMESTAMP
FROM [ABSC].[dbo].[_AB_tb_FBO_W99_Initial_PurchaseOrder_Receipts]  as iPOr WITH (ROWLOCK, NOWAIT)
WHERE 1=1
	AND iPOr.rowstatus = 1 -- being processed
	AND iPOr.transportOrderNr IS NOT NULL -- Transport Order has been listed
	AND iPOr.transportOrderLineId IS NOT NULL -- Transport Order Line has been listed


-- Not Yet succeeded

--UPDATE iPOr  SET
SELECT *,
    [retry_counter] = iPOr.[retry_counter] + 1
	, [sysmessage] = 
		CASE WHEN iPOr.[sysmessage]  IS NULL 
			THEN 'Transport Order or Order Line NOT Listed'
			ELSE 'Transport Order or Order Line NOT Listed' + CHAR(13) + CHAR(10) 
				+ iPOr.[sysmessage] END
 	, sysmodified = CURRENT_TIMESTAMP
FROM [ABSC].[dbo].[_AB_tb_FBO_W99_Initial_PurchaseOrder_Receipts]  as iPOr WITH (ROWLOCK, NOWAIT) 
WHERE 1=1
	AND iPOr.rowstatus = 1 -- being processed
	AND (iPOr.transportOrderNr IS NOT NULL -- Transport Order has been listed
		 OR	iPOr.transportOrderLineId IS NOT NULL -- Transport Order Line has been listed
		)


SELECT iPOr.transportOrderNr, olt.OrderNumber, iPOr.orderLineId, olt.Field02, *,
    [sysmessage] = 
        CASE ISNULL(EntR.rowstatus,-1) 
        WHEN 2 THEN 'Transport Order & Order Line Created'
        ELSE 
            CASE WHEN iPOr.[sysmessage]  IS NULL 
                THEN ISNULL(EntR.errormessage, 'No result for Order Line found')
                ELSE ISNULL(EntR.errormessage, 'No result for Order Line found') + CHAR(13) + CHAR(10) 
                    + iPOr.[sysmessage] 
            END 
        END
    , sysmodified = CURRENT_TIMESTAMP
    , [transportOrderLineId] = ISNULL(iPOr.[transportOrderLineId], ol.ID) -- SHOULD FAIL When iPOr.[transportOrderLineId] IS NOT NULL
FROM [ABSC].[dbo].[_AB_tb_FBO_W99_Initial_PurchaseOrder_Receipts]  as iPOr WITH (NOLOCK)
    -- Results for lines
    LEFT OUTER JOIN [ABEI].dbo._AB_Entity_results EntR with (nolock) 
        ON 1 = 1 -- '%runid%' = EntR.runid --Explicitely this run only
        and EntR.jobid =  1331 -- %jobid%
        and EntR.Entity = 'PurchaseOrderLine'
        and EntR.Action = 'create'
        and EntR.ReferenceValue = iPOr.[orderLineID]
    LEFT OUTER JOIN [115].dbo.AdditionalOrderLines as olt WITH (NOLOCK)
        ON olt.OrderNumber =  iPOr.transportOrderNr 
			AND  iPOr.[orderLineID] = CAST(olt.Field02 as INT)-- '473379'
    LEFT OUTER JOIN [115].[dbo].[orsrg] as ol WITH (NOLOCK)
        ON olt.OrderNumber = ol.ordernr
        AND olt.LineNumber = ol.regel
WHERE iPOr.rowstatus = 1 -- being processed
    AND iPOr.transportOrderNr IS NOT NULL -- Transport Order has been listed
*/



SELECT --top 100
	oh.*
FROM [115].dbo.orkrg oh (NOLOCK)
INNER JOIN [115].dbo.orsrg ol (NOLOCK)
	ON oh.ordernr = ol.ordernr
LEFT JOIN [115].dbo.AdditionalOrderHeader oht
	ON oht.OrderNumber = oh.ordernr

WHERE 1=1
	AND oht.Field09 IS NOT NULL
ORDER BY ordbv_afgd DESC

	/*
	SELECT TOP 100 *
	FROM [115].dbo.AdditionalOrderHeader oht
	--WHERE Field02 IS NOT NULL
	ORDER BY syscreated DESC

	--AdditionalOrderHeader

	SELECT TOP 100 *
	FROM [115].dbo.AdditionalOrderLines olt
--	WHERE Field02 IS NOT NULL
	ORDER BY syscreated DESC
	--504251
SELECT * FROM [ABEI].dbo._AB_Entity_results EntR with (nolock) 
    WHERE 1=1 -- '%runid%' = rh.runid --Explicitely this run only
        and EntR.jobid = 1331 -- %jobid%
        and EntR.Entity = 'PurchaseOrderHeader'
        and EntR.Action = 'create'
		and EntR.rowstatus = 2
		--and EntR.NewKeyvalue IS NOT NULL
	ORDER BY syscreated DESC
	-- OL Record Value: 929431
	-- OL Header ID: 23436204
	-- OL ReferenceValue: 338580
		-- Created TO: 90054896
SELECT TOP 100
	*
FROM [115].dbo.gbkmut
--WHERE ID = 856378
ORDER BY syscreated DESC

*/