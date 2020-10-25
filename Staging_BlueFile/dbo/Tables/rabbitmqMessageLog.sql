CREATE TABLE [dbo].[rabbitmqMessageLog] (
    [rabbitMQmessage] NVARCHAR (MAX)  NULL,
    [routingKey]      NVARCHAR (100)  NULL,
    [errorMessage]    NVARCHAR (1000) NULL,
    [loadDate]        DATETIME        NULL
);

