CREATE TABLE [dbo].[PazientiAttributiDizionario] (
    [Nome] VARCHAR (64) NOT NULL,
    CONSTRAINT [PK_PazientiAttributiDizionario] PRIMARY KEY CLUSTERED ([Nome] ASC),
    CONSTRAINT [CK_PazientiAttributiDizionario_Nome] CHECK ([Nome]<>'')
);


GO
CREATE NONCLUSTERED INDEX [IX_PazientiAttributiDizionario]
    ON [dbo].[PazientiAttributiDizionario]([Nome] ASC);

