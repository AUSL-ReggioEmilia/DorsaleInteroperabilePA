CREATE TABLE [dbo].[Log] (
    [Id]             INT          IDENTITY (1, 1) NOT NULL,
    [DataVariazione] DATETIME     NOT NULL,
    [IdLHA]          VARCHAR (20) NOT NULL,
    [TipoOperazione] VARCHAR (1)  NOT NULL,
    [XmlMessaggio]   XML          NOT NULL,
    [DataLog]        DATETIME     CONSTRAINT [DF_Log_DataLog] DEFAULT (getdate()) NOT NULL,
    [DaFullSync]     BIT          NULL,
    CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);


GO
CREATE NONCLUSTERED INDEX [IX_Log_IdLHA]
    ON [dbo].[Log]([IdLHA] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Log_DataLog]
    ON [dbo].[Log]([DataLog] ASC) WITH (FILLFACTOR = 95);

