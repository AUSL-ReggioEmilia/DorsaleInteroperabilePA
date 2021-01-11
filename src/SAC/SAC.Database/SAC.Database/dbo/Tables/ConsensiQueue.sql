CREATE TABLE [dbo].[ConsensiQueue] (
    [IdSeq]                       UNIQUEIDENTIFIER CONSTRAINT [DF_ConsensiQueue_IdSeq] DEFAULT (newsequentialid()) NOT NULL,
    [DataOperazione]              DATETIME         CONSTRAINT [DF_ConsensiQueue_DataLog] DEFAULT (getdate()) NOT NULL,
    [Utente]                      VARCHAR (64)     CONSTRAINT [DF_ConsensiQueue_Utente] DEFAULT (user_name()) NOT NULL,
    [Operazione]                  TINYINT          CONSTRAINT [DF_ConsensiQueue_Operazione] DEFAULT ((0)) NOT NULL,
    [Id]                          VARCHAR (64)     NULL,
    [Tipo]                        VARCHAR (64)     NOT NULL,
    [DataStato]                   DATETIME         NOT NULL,
    [Stato]                       BIT              NOT NULL,
    [OperatoreId]                 VARCHAR (64)     NULL,
    [OperatoreCognome]            VARCHAR (64)     NULL,
    [OperatoreNome]               VARCHAR (64)     NULL,
    [OperatoreComputer]           VARCHAR (64)     NULL,
    [PazienteProvenienza]         VARCHAR (16)     NULL,
    [PazienteProvenienzaId]       VARCHAR (64)     NULL,
    [PazienteCognome]             VARCHAR (64)     NULL,
    [PazienteNome]                VARCHAR (64)     NULL,
    [PazienteCodiceFiscale]       VARCHAR (16)     CONSTRAINT [DF_ConsensiQueue_PazienteCodiceFiscale] DEFAULT ('0000000000000000') NULL,
    [PazienteDataNascita]         DATETIME         NULL,
    [PazienteComuneNascitaCodice] VARCHAR (6)      NULL,
    [PazienteNazionalitaCodice]   VARCHAR (3)      NULL,
    [PazienteTessera]             VARCHAR (16)     NULL,
    CONSTRAINT [PK_ConsensiQueue] PRIMARY KEY CLUSTERED ([IdSeq] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_ConsensiQueue_ConsensiTipo] FOREIGN KEY ([Tipo]) REFERENCES [dbo].[ConsensiTipo] ([Nome]),
    CONSTRAINT [FK_ConsensiQueue_Utenti] FOREIGN KEY ([Utente]) REFERENCES [dbo].[Utenti] ([Utente])
);


GO
CREATE NONCLUSTERED INDEX [IX_ConsensiQueue_Data]
    ON [dbo].[ConsensiQueue]([DataOperazione] ASC) WITH (FILLFACTOR = 95);


GO
CREATE TRIGGER [dbo].[TrgConsensiQueueIns] 
   ON  [dbo].[ConsensiQueue] 
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	IF [dbo].[LeggeConsensiPermessiScrittura](NULL) = 0
	BEGIN
		ROLLBACK

		EXEC ConsensiEventiAccessoNegato USER_NAME, 0, 'ConsensiQueue', 'Utente non ha i permessi di scrittura!'

		RAISERROR (N'Utente non ha i permessi di scrittura!', 10, 1)
	END
END
