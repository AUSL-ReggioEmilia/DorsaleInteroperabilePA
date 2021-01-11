CREATE TABLE [sinottico].[UltimiArriviEventi] (
    [AziendaErogante] VARCHAR (16) NOT NULL,
    [SistemaErogante] VARCHAR (16) NOT NULL,
    [DataArrivo]      DATETIME     NOT NULL,
    CONSTRAINT [PK_UltimiArriviEventi_AziendaErogante_SistemaErogante] PRIMARY KEY CLUSTERED ([AziendaErogante] ASC, [SistemaErogante] ASC) WITH (FILLFACTOR = 40)
);

