CREATE TABLE [dbo].[UtentiGruppiDominio] (
    [UserName]          VARCHAR (64)  NOT NULL,
    [DataModifica]      DATETIME2 (3) NOT NULL,
    [CacheGruppiUtente] XML           NULL,
    CONSTRAINT [PK_UtentiGruppiDominio] PRIMARY KEY CLUSTERED ([UserName] ASC) WITH (FILLFACTOR = 70)
);

