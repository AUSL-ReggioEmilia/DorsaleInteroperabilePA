CREATE TABLE [dbo].[Log] (
    [ID]                  UNIQUEIDENTIFIER CONSTRAINT [DF_Log_ID] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [IDOrdineTestata]     UNIQUEIDENTIFIER NOT NULL,
    [DataStoricizzazione] DATETIME2 (0)    CONSTRAINT [DF_Log_DataStoricizzazione] DEFAULT (getdate()) NOT NULL,
    [Errore]              VARCHAR (MAX)    NULL,
    CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);

