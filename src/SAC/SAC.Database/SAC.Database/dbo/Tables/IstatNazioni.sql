CREATE TABLE [dbo].[IstatNazioni] (
    [Codice]             VARCHAR (3)  NOT NULL,
    [Nome]               VARCHAR (64) NOT NULL,
    [DataInizioValidita] DATETIME     CONSTRAINT [DF_IstatNazioni_DataInizioValidita] DEFAULT ('1800-01-01') NULL,
    [DataFineValidita]   DATETIME     NULL,
    [FlagPaeseUE]        VARCHAR (1)  NULL,
    [DataUltimaModifica] DATETIME     NULL,
    [CodiceInternoLHA]   VARCHAR (3)  NULL,
    CONSTRAINT [PK_IstatNazioni] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[IstatNazioni] TO [DataAccessSql]
    AS [dbo];

