import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { UpdateCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient();

export const handler = async (event) => {
    const { userId } = event.pathParameters;
    const { firstName, lastName } = JSON.parse(event.body);
    const tableName = process.env.TABLE_NAME;

    const params = {
        TableName: tableName,
        Key: {
            id: userId,
        },
        UpdateExpression: "set firstName = :f, lastName = :l",
        ExpressionAttributeValues: {
            ":f": firstName,
            ":l": lastName,
        },
        ReturnValues: "ALL_NEW",
    };

    try {
        const data = await client.send(new UpdateCommand(params));
        return {
            statusCode: 200,
            body: JSON.stringify(data.Attributes),
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Erreur lors de la mise à jour de l\'utilisateur' }),
        };
    }
};
