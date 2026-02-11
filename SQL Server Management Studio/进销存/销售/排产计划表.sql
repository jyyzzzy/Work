INSERT
	INTO
		RDSJK..APS_ShedulDetails
SELECT *,
	GETDATE() AS C_REATE
	FROM
		OPENQUERY([APS_RDKJ_PRD], 'select  ID,make_order_num,classes_start_time,plan_qty,processName,DESCRIPTIONS,REQ_NUMBER,CREATION_DATE from v_aps_sheduldetails where
 CREATION_DATE>=DATE_ADD(NOW(), INTERVAL -3 DAY)')

INSERT
	INTO
		RDSJK..APS_ShedulDetails
		(
			ID,
			make_order_num,
			classes_start_time,
			plan_qty,
			processName,
			DESCRIPTIONS,
			REQ_NUMBER,
			CREATION_DATE,
			C_REATE
		)
SELECT
	E.ID,
	E.make_order_num,
	E.classes_start_time,
	E.plan_qty,
	E.processName,
	E.DESCRIPTIONS,
	E.REQ_NUMBER,
	E.CREATION_DATE,
	GETDATE()
	FROM
		(
			SELECT
				ID,
				make_order_num,
				classes_start_time,
				plan_qty,
				processName,
				DESCRIPTIONS,
				REQ_NUMBER,
				CREATION_DATE
				FROM
					OPENQUERY(
							[APS_RDKJ_PRD],
							'SELECT ID,make_order_num,classes_start_time,plan_qty,processName,DESCRIPTIONS,REQ_NUMBER,CREATION_DATE
							 FROM v_aps_sheduldetails
							 WHERE CREATION_DATE >= DATE_ADD(NOW(), INTERVAL -3 DAY)'
					)
			EXCEPT
			SELECT
				ID,
				make_order_num,
				classes_start_time,
				plan_qty,
				processName,
				DESCRIPTIONS,
				REQ_NUMBER,
				CREATION_DATE
				FROM
					RDSJK..APS_ShedulDetails
				WHERE
					CREATION_DATE >= DATEADD(DAY, -3, GETDATE())
		) AS E;

SELECT *
	FROM
		RDSJK..APS_ShedulDetails
	ORDER BY
		C_REATE DESC