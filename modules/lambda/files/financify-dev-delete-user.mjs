import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DeleteCommand } from "@aws-sdk/lib-dynamodb";

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
        await client.send(new DeleteCommand(params));
        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Utilisateur supprimé avec succès' }),
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Erreur lors de la suppression de l\'utilisateur' }),
        };
    }
};
