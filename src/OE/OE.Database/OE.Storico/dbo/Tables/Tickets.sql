CREATE TABLE [dbo].[Tickets] (
    [ID]            UNIQUEIDENTIFIER NOT NULL,
    [DataCreazione] DATETIME2 (0)    NOT NULL,
    [DataLettura]   DATETIME2 (0)    NOT NULL,
    [IDUtente]      UNIQUEIDENTIFIER NOT NULL,
    [UserName]      VARCHAR (64)     NOT NULL,
    [TTL]           INT              NOT NULL,
    CONSTRAINT [PK_Tickets] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [IX_DataLettura]
    ON [dbo].[Tickets]([DataLettura] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_IdUtenteUserName]
    ON [dbo].[Tickets]([UserName] ASC, [IDUtente] ASC)
    INCLUDE([DataLettura]) WITH (FILLFACTOR = 70);

