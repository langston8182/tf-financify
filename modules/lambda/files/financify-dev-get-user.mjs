import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { GetCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient();

export const handler = async (event) => {
    const { userId } = event.pathParameters;
    const tableName = process.env.TABLE_NAME;

    const params = {
        TableName: tableName,
        Key: {
            id: userId,
        },
    };

    try {
        const data = await client.send(new GetCommand(params));
        if (data.Item) {
            return {
                statusCode: 200,
                body: JSON.stringify(data.Item),
            };
        } else {
            return {
                statusCode: 404,
                body: JSON.stringify({ message: 'Utilisateur non trouvé' }),
            };
        }
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Erreur lors de la récupération de l\'utilisateur' }),
        };
    }
};
