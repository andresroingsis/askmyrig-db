CREATE TABLE [dbo].[Chunks] (
    [Id]        BIGINT         IDENTITY (1, 1) NOT NULL,
    [ManualId]  INT            NOT NULL,
    [PageFrom]  INT            NOT NULL,
    [PageTo]    INT            NOT NULL,
    [Heading]   NVARCHAR (400) NULL,
    [Content]   NVARCHAR (MAX) NOT NULL,
    [Tokens]    INT            NOT NULL,
    [Embedding] VECTOR(768)    NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([ManualId]) REFERENCES [dbo].[Manuals] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_Chunks_ManualId]
    ON [dbo].[Chunks]([ManualId] ASC);


GO

