CREATE TABLE [dbo].[PazientiSinonimi] (
    [Id]                  UNIQUEIDENTIFIER CONSTRAINT [DF_PazientiSinomini_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [IdPaziente]          UNIQUEIDENTIFIER NOT NULL,
    [Provenienza]         VARCHAR (16)     NOT NULL,
    [IdProvenienza]       VARCHAR (64)     NOT NULL,
    [ProgressivoSinonimo] INT              CONSTRAINT [DF_PazientiSinonimi_ProgressivoSinonimo] DEFAULT ((0)) NOT NULL,
    [Abilitato]           BIT              CONSTRAINT [DF_PazientiSinonimi_Abilitato] DEFAULT ((1)) NOT NULL,
    [DataInserimento]     DATETIME         CONSTRAINT [DF_PazientiSinomini_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [Motivo]              TINYINT          CONSTRAINT [DF_PazientiSinomini_Motivo] DEFAULT ((0)) NOT NULL,
    [Note]                TEXT             NULL,
    CONSTRAINT [PK_PazientiSinonimi] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_PazientiSinonimi_Pazienti] FOREIGN KEY ([IdPaziente]) REFERENCES [dbo].[Pazienti] ([Id]),
    CONSTRAINT [FK_PazientiSinonimi_Provenienze] FOREIGN KEY ([Provenienza]) REFERENCES [dbo].[Provenienze] ([Provenienza])
);


GO
CREATE CLUSTERED INDEX [FK_PazientiSinonimi_IdPaziente]
    ON [dbo].[PazientiSinonimi]([IdPaziente] ASC, [ProgressivoSinonimo] DESC) WITH (FILLFACTOR = 95);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProvenienzaIdProvenienza]
    ON [dbo].[PazientiSinonimi]([Provenienza] ASC, [IdProvenienza] ASC, [ProgressivoSinonimo] ASC) WITH (FILLFACTOR = 95);


GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[PazienteSinonimiAttivi_Del]
   ON  [dbo].[PazientiSinonimi] 
   AFTER DELETE
AS 
BEGIN

	SET NOCOUNT ON;
	-- 
	-- Controlla il campo abilitato
	-- 
	UPDATE PazientiSinonimi
	SET Abilitato = CASE ProgressivoSinonimo WHEN (SELECT MAX(ProgressivoSinonimo)
												FROM PazientiSinonimi pf1
												WHERE pf1.Provenienza = pf2.Provenienza
												AND pf1.IdProvenienza = pf2.IdProvenienza)
											THEN 1 ELSE 0 END
	FROM PazientiSinonimi pf2 INNER JOIN
			(SELECT Provenienza, IdProvenienza
			FROM DELETED
			GROUP BY Provenienza, IdProvenienza) del
		ON pf2.Provenienza = del.Provenienza
			AND pf2.IdProvenienza = del.IdProvenienza
END

GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[PazienteSinonimiAttivi_InsUpd]
   ON  [dbo].[PazientiSinonimi] 
   AFTER INSERT, UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	
	IF UPDATE(Abilitato) OR UPDATE(Provenienza) OR UPDATE(IdProvenienza) OR UPDATE(ProgressivoSinonimo)
	BEGIN
		-- 
		-- Controlla il campo abilitato
		-- 
		UPDATE PazientiSinonimi
		SET ProgressivoSinonimo = 1 + (SELECT MAX(ProgressivoSinonimo)
									FROM PazientiSinonimi pf1
									WHERE pf1.Provenienza = pf2.Provenienza
									AND pf1.IdProvenienza = pf2.IdProvenienza)

		FROM PazientiSinonimi pf2 INNER JOIN
				(SELECT Provenienza, IdProvenienza
				FROM INSERTED
				GROUP BY Provenienza, IdProvenienza) ins
			ON pf2.Provenienza = ins.Provenienza
				AND pf2.IdProvenienza = ins.IdProvenienza

			AND ProgressivoSinonimo = 0
		-- 
		-- Controlla il campo abilitato
		-- 
		UPDATE PazientiSinonimi
		SET Abilitato = CASE ProgressivoSinonimo WHEN (SELECT MAX(ProgressivoSinonimo)
													FROM PazientiSinonimi pf1
													WHERE pf1.Provenienza = pf2.Provenienza
													AND pf1.IdProvenienza = pf2.IdProvenienza)
												THEN 1 ELSE 0 END
		
		FROM PazientiSinonimi pf2 INNER JOIN
				(SELECT Provenienza, IdProvenienza
				FROM INSERTED
				GROUP BY Provenienza, IdProvenienza) ins
			ON pf2.Provenienza = ins.Provenienza
				AND pf2.IdProvenienza = ins.IdProvenienza
	END
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Dipartimentale; 1=Input merge CF; 2=Batch merge CF; 3=UI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PazientiSinonimi', @level2type = N'COLUMN', @level2name = N'Motivo';

