DECLARE @stepName [varchar](255) = 'EG: Check for new TransportOrder Deliveries'

INSERT INTO [%abeitargetdb%].[dbo].[%Tablename_Preceder%_Log] (ExactDbNum, jobid, jobstepid, runid, SYSCREATED, SUBJECT, MESSAGE )
VALUES (%param_eg_division%, %jobid%, %jobstepid%, '%runid%', CURRENT_TIMESTAMP, @stepName, 'Looking for newly delivered created Transport Orders.')

DECLARE @numToProcess int

INSERT INTO [%abeitargetdb%].[dbo].[%Tablename_Preceder%_Created_TransportOrder_Receipts] (syscreated, sysmodified, runId, rowstatus, sysmessage, ExactDbNum,
    [bkstnr], -- varchar(20) NOT NULL, -- ontvangst boeking nummer (varchar(20))
    [datumOntvangst],-- datetime NOT NULL,
    [ordernr], --CHAR(8) NOT NULL,
    [levwijze], --CHAR(5) NOT NULL,
    [planned_deliveryDate], -- datetime NOT NULL,
    initalPurchaseOrderNr,
    [orderLineID], -- int NOT NULL,
    initalPurchaseOrderLineId,
    [artcode], -- varchar(30) NOT NULL
    [aantal], -- float NOT NULL default 0,
    -- From Items
    PackageDescription, --  char(8) null,
    GLAccountDistribution, -- varchar(9) NULL,
    GLAccountCost, --  varchar(9) NULL,
    GLPriceDifference,
    [CostPriceCurrency], --  varchar(3) NULL,
    -- Original inital PO Receipt CostPrice OR latest recount / value of inventory in WareHouse 99
    CurrentInventoryCostPrice --  float NOT NULL DEFAULT 0,
    [magcode_FoB], -- FO-48 Extend CD 04.345.682
    [magcode]       -- FO-48 Extend CD 04.345.682
)
SELECT
    CURRENT_TIMESTAMP as syscreated, CURRENT_TIMESTAMP as [sysmodified], '%runid%' as runId, 0 as rowstatus, @stepName as sysmessage, %param_eg_division% as ExactDbNum,
    receipts.bkstnr -- ontvangst boeking nummer (varchar(20))
    , receipts.datum as datumOntvangst
    , receipts.ordernr
    , receipts.levwijze as levwijze
    , receipts.afldat as planned_deliveryDate
    , receipts.[initalPurchaseOrderNr]      -- %param_order_Header_additionalfield_name% -- Field09
    , egOL.ID as orderLineID --(int)
    , egOLa.[%param_order_Line_additionalfield_name%] as [initalPurchaseOrderLineId]  -- Field09
    , GM.artcode -- (varchar(30))
    , GM.aantal  -- float
    , IT.PackageDescription
    , IT.GLAccountDistribution
    , IT.GLAccountCost
    , ITG.GLPriceDifference
    , IT.[CostPriceCurrency]
    , ISNULL(
        CASE WHEN GMartRecount.aantal IS NULL
        THEN CASE WHEN ISNULL(GMiPOreceive.aantal, 0) = 0
                THEN ISNULL(GMiPOreceive.bdr_val, 0)
                ELSE ROUND(ISNULL(GMiPOreceive.bdr_val, 0) / GMiPOreceive.aantal, 3) -- 3 digits
            END
        ELSE CASE WHEN ISNULL(GMartRecount.aantal, 0) = 0
                THEN ISNULL(GMartRecount.bdr_val, 0)
                ELSE ROUND(ISNULL(GMartRecount.bdr_val, 0) / GMartRecount.aantal, 3) -- 3 digits
            END
        END
    , IT.[CostPriceStandard]) as CurrentInventoryCostPrice
    , receipts.magcode_FoB
    , receipts.magcode
FROM (SELECT DISTINCT TOP  %param_number_of_records_per_run%            -- MAX num records: bkstnr: Receipt slips
          currentRunGM.bkstnr
        , currentRunGM.datum
        , currentRunEgOH.ordernr
        , currentRunEgOH.levwijze
        , currentRunEgOH.afldat
        , currentRunEgOHa.[%param_order_Header_additionalfield_name%] as [initalPurchaseOrderNr]        -- %param_order_Header_additionalfield_name% : Field09
        , currentRunEgOH.magcode    -- FO-48 Extend CD 04.345.682
        , CASE currentRunEgOH.magcode
            WHEN '03' THEN '99'
            WHEN '16' THEN '98'
            END as magcode_FoB -- FO-48 Extend CD 04.345.682
        FROM [%abeisourcedb%].[dbo].[gbkmut] AS currentRunGM WITH (NOLOCK)
        INNER JOIN [%abeisourcedb%].[dbo].[Items] AS currentRunIT WITH (NOLOCK)
            ON currentRunIT.ItemCode = currentRunGM.artcode
            AND currentRunGM.reknr = currentRunIT.GLAccountDistribution         -- Filter voorraad boekingen
        INNER JOIN [%abeisourcedb%].[dbo].[orkrg] AS currentRunEgOH WITH (NOLOCK)
            ON currentRunEgOH.ordernr = currentRunGM.bkstnr_sub
        INNER JOIN [%abeisourcedb%].dbo.AdditionalOrderHeader currentRunEgOHa
            ON currentRunEgOHa.OrderNumber = currentRunEgOH.ordernr
        LEFT JOIN [%abeitargetdb%].[dbo].[%Tablename_Preceder%_Created_TransportOrder_Receipts] AS cTOr WITH (NOLOCK)
            ON currentRunGM.bkstnr = cTOr.bkstnr
        WHERE 1=1
            -- Filter receipts in Warehouse 03
            AND currentRunGM.transtype = 'N'                    -- Gerealiseerd (itt Gepland 'B')
            AND currentRunGM.transsubtype = 'A'                 -- Spullen
            AND currentRunGM.warehouse IN ('03', '16')          -- FO-48 Extend CD 04.345.682
            AND currentRunGM.datum >='%param_from_afldat%'      -- Filter for starting in Production

            -- Filter Transport Orders
            AND currentRunEgOH.ord_soort = 'B'                          -- Purchase Order
            AND currentRunEgOH.selcode = 'TR'                           -- Marked selcode by Task01 Step 100  - %param_TransportOrder_SelectionCode%
            AND currentRunEgOHa.[%param_order_Header_additionalfield_name%] IS NOT NULL -- %param_order_Header_additionalfield_name%
            -- NOT already in process
            AND cTOr.ID IS NULL
        ORDER BY currentRunGM.datum ASC
    ) as receipts
INNER JOIN [%abeisourcedb%].[dbo].[gbkmut] AS GM WITH (NOLOCK)
    ON GM.bkstnr = receipts.bkstnr
INNER JOIN [%abeisourcedb%].[dbo].[Items] AS IT WITH (NOLOCK)
    ON IT.ItemCode = GM.artcode
    AND GM.reknr = IT.GLAccountDistribution         -- Filter voorraad boekingen
INNER JOIN [%abeisourcedb%].[dbo].[ItemAssortment] as ITG WITH (NOLOCK)
    ON IT.Assortment = ITG.Assortment
INNER JOIN [%abeisourcedb%].[dbo].[orsrg] AS egOL WITH (NOLOCK)
    on egOL.sysguid = GM.LinkedLine
INNER JOIN [%abeisourcedb%].dbo.AdditionalOrderHeader egOHa
    ON egOHa.OrderNumber = egOL.ordernr
    AND egOHa.[%param_order_Header_additionalfield_name%]  IS NOT NULL                     -- Field09
INNER JOIN [%abeisourcedb%].dbo.AdditionalOrderLines egOLa WITH (NOLOCK)
    ON egOLa.OrderNumber = egOL.ordernr
    AND egOLa.LineNumber = egOL.regel
    AND egOLa.[%param_order_Line_additionalfield_name%] IS NOT NULL                   -- Field09
INNER JOIN [%abeisourcedb%].[dbo].[orsrg] iPOegOL WITH (NOLOCK)
    ON  LTRIM(RTRIM(STR(iPOegOL.ID))) = egOLa.[%param_order_Line_additionalfield_name%] COLLATE DATABASE_DEFAULT
INNER JOIN [%abeisourcedb%].[dbo].[gbkmut] GMiPOreceive
    ON GMiPOreceive.LinkedLine = iPOegOL.sysguid
    AND GMiPOreceive.reknr = IT.GLAccountDistribution -- actual Inventory Line (as opposed to NOG/NSF)
OUTER APPLY (SELECT TOP 1
                GMrecount.artcode,
                GMrecount.datum,
                GMrecount.aantal,
                GMrecount.bdr_val
                FROM [%abeisourcedb%].[dbo].[gbkmut] GMrecount
                WHERE   GMrecount.artcode = GM.artcode
                    AND GMrecount.reknr = IT.GLAccountDistribution
                    AND GMrecount.transtype = 'N'
                    AND GMrecount.transsubtype = 'G'
                    AND GMrecount.warehouse = receipts.magcode_FoB          -- FO-48 Extend CD 04.345.682
                    AND GMrecount.datum >= GMiPOreceive.datum
                    AND GMrecount.datum <= GM.datum
                    AND GMrecount.bdr_val >= 0
                ORDER BY GMrecount.ID DESC
) as GMartRecount


SELECT @numToProcess=@@ROWCOUNT

INSERT INTO [%abeitargetdb%].[dbo].[%Tablename_Preceder%_Log] (ExactDbNum, jobid, jobstepid, runid, SYSCREATED, SUBJECT, MESSAGE )
VALUES (%param_eg_division%, %jobid%, %jobstepid%, '%runid%', CURRENT_TIMESTAMP, @stepName, 'Found: ' + CONVERT(varchar(10), @numToProcess)+ ' newly delivered created Transport Orders' )


-- 'Transaction Log' for T-Shoot and insight in retries....
INSERT INTO [%abeitargetdb%].[dbo].[%Tablename_Preceder%_Log] (ExactDbNum, jobid, jobstepid, runid, SYSCREATED, SUBJECT
    , bkstnr
    , ordernr
    , orderLineID
    , MESSAGE 
    , [magcode_FoB] -- FO-48 Extend CD 04.345.682
    , [magcode]       -- FO-48 Extend CD 04.345.682
)
SELECT %param_eg_division%, %jobid%, %jobstepid%, '%runid%', CURRENT_TIMESTAMP, @stepName
    , cTOr.bkstnr
    , cTOr.ordernr
    , cTOr.orderLineID
    , 'Receipt for created Transport Order detected.'
    , cTOr.[magcode_FoB]
    , cTOr.[magcode]
FROM [%abeitargetdb%].[dbo].[%Tablename_Preceder%_Created_TransportOrder_Receipts]  as cTOr WITH (NOLOCK)
WHERE cTOr.rowstatus = 0 -- TODO
    AND '%runid%' = cTOr.runid --Explicitely this run only
                