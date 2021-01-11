CREATE TABLE [dbo].[PazientiFusioni] (
    [Id]                 UNIQUEIDENTIFIER CONSTRAINT [DF_PazientiFusioni_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [IdPaziente]         UNIQUEIDENTIFIER NOT NULL,
    [IdPazienteFuso]     UNIQUEIDENTIFIER NOT NULL,
    [ProgressivoFusione] INT              CONSTRAINT [DF_PazientiFusioni_ProgressivoFusione] DEFAULT ((0)) NOT NULL,
    [Abilitato]          BIT              CONSTRAINT [DF_PazientiFusioni_Abilitato] DEFAULT ((1)) NOT NULL,
    [DataInserimento]    DATETIME         CONSTRAINT [DF_PazientiFusioni_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [Motivo]             TINYINT          CONSTRAINT [DF_PazientiFusioni_Motivo] DEFAULT ((0)) NOT NULL,
    [Note]               TEXT             NULL,
    CONSTRAINT [PK_PazientiFusioni] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_PazientiFusioni_IdPazienteFuso] FOREIGN KEY ([IdPazienteFuso]) REFERENCES [dbo].[Pazienti] ([Id]),
    CONSTRAINT [FK_PazientiFusioni_Pazienti] FOREIGN KEY ([IdPaziente]) REFERENCES [dbo].[Pazienti] ([Id])
);


GO
CREATE CLUSTERED INDEX [FK_IdPaziente]
    ON [dbo].[PazientiFusioni]([IdPaziente] ASC) WITH (FILLFACTOR = 95);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IdPazienteFuso]
    ON [dbo].[PazientiFusioni]([IdPazienteFuso] ASC, [ProgressivoFusione] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_PazienteAbilitato]
    ON [dbo].[PazientiFusioni]([Abilitato] ASC, [IdPaziente] ASC, [IdPazienteFuso] ASC) WITH (FILLFACTOR = 95);


GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[PazienteFusioniAttivi_Del]
   ON  [dbo].[PazientiFusioni] 
   AFTER DELETE
AS 
BEGIN

	SET NOCOUNT ON;
	-- 
	-- Controlla il campo abilitato
	-- 
	UPDATE PazientiFusioni
	SET Abilitato = CASE ProgressivoFusione WHEN (SELECT MAX(ProgressivoFusione)
													FROM PazientiFusioni pf1
													WHERE pf1.IdPazienteFuso=pf2.IdPazienteFuso)
											THEN 1 ELSE 0 END
	FROM PazientiFusioni pf2
	WHERE IdPazienteFuso IN (SELECT IdPazienteFuso
							FROM DELETED
							GROUP BY IdPazienteFuso)
END

GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[PazienteFusioniAttivi_InsUpd]
   ON  [dbo].[PazientiFusioni] 
   AFTER INSERT, UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	
	IF UPDATE(Abilitato) OR UPDATE(IdPazienteFuso) OR UPDATE(ProgressivoFusione)
	BEGIN
		-- 
		-- Controlla progressivo solo in insert
		-- 
		UPDATE PazientiFusioni
		SET ProgressivoFusione = (SELECT MAX(ProgressivoFusione)
									FROM PazientiFusioni pf1
									WHERE pf1.IdPazienteFuso=pf2.IdPazienteFuso) + 1
		FROM PazientiFusioni pf2
		WHERE IdPazienteFuso IN (SELECT IdPazienteFuso
								FROM INSERTED
								GROUP BY IdPazienteFuso)
			AND ProgressivoFusione = 0
		-- 
		-- Controlla il campo abilitato
		-- 
		UPDATE PazientiFusioni
		SET Abilitato = CASE ProgressivoFusione WHEN (SELECT MAX(ProgressivoFusione)
														FROM PazientiFusioni pf1
														WHERE pf1.IdPazienteFuso=pf2.IdPazienteFuso)
												THEN 1 ELSE 0 END
		FROM PazientiFusioni pf2
		WHERE IdPazienteFuso IN (SELECT IdPazienteFuso
								FROM INSERTED
								GROUP BY IdPazienteFuso)
	END	
END

GO
GRANT SELECT
    ON OBJECT::[dbo].[PazientiFusioni] TO [DataAccessDwhFusioni]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Dipartimentale; 1=Input merge CF; 2=Batch merge CF; 3=UI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PazientiFusioni', @level2type = N'COLUMN', @level2name = N'Motivo';

