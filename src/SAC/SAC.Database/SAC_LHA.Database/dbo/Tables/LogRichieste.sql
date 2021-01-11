CREATE TABLE [dbo].[LogRichieste] (
    [Id]                    INT          IDENTITY (1, 1) NOT NULL,
    [DataRichiesta]         DATETIME     CONSTRAINT [DF_LogRichieste_DataRichiesta] DEFAULT (getdate()) NOT NULL,
    [IdLHA]                 VARCHAR (20) NOT NULL,
    [TipoOperazione]        VARCHAR (1)  NOT NULL,
    [XmlMessaggioPersona]   XML          NOT NULL,
    [XmlMessaggioEsenzioni] XML          NOT NULL,
    [XmlMessaggioConsensi]  XML          NOT NULL,
    CONSTRAINT [PK_LogRichieste] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [IX_LogRichieste_DataRichiesta]
    ON [dbo].[LogRichieste]([DataRichiesta] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_LogRichieste_IdLHA]
    ON [dbo].[LogRichieste]([IdLHA] ASC) WITH (FILLFACTOR = 95);

