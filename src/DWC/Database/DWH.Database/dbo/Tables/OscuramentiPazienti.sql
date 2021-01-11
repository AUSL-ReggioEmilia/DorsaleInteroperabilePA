CREATE TABLE [dbo].[OscuramentiPazienti] (
    [IdPaziente]             UNIQUEIDENTIFIER NOT NULL,
    [DataModifica]           DATETIME         CONSTRAINT [DF_OscuramentiPazienti_DataModifica] DEFAULT (getdate()) NOT NULL,
    [UtenteModifica]         VARCHAR (64)     CONSTRAINT [DF_OscuramentiPazienti_UtenteModifica] DEFAULT (suser_name()) NOT NULL,
    [OscuraReferti]          BIT              CONSTRAINT [DF_OscuramentiPazienti_OscuraReferto] DEFAULT ((0)) NOT NULL,
    [OscuraRicoveri]         BIT              CONSTRAINT [DF_OscuramentiPazienti_OscuraRicovero] DEFAULT ((0)) NOT NULL,
    [OscuraPrescrizioni]     BIT              CONSTRAINT [DF_OscuramentiPazienti_OscuraPrescrizioni] DEFAULT ((0)) NOT NULL,
    [OscuraNoteAnamnestiche] BIT              CONSTRAINT [DF_OscuramentiPazienti_OscuraNoteAnamnestiche] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_OscuramentiPazienti] PRIMARY KEY CLUSTERED ([IdPaziente] ASC)
);

