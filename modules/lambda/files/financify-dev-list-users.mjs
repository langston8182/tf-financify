import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { ScanCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient();

export const handler = async (event) => {
    const tableName = process.env.TABLE_NAME;

    const params = {
        TableName: tableName,
    };

    try {
        const data = await client.send(new ScanCommand(params));
        return {
            statusCode: 200,
            body: JSON.stringify(data.Items),
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Erreur lors de la récupération des utilisateurs' }),
        };
    }
};
