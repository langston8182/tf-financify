import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { PutCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient();

export const handler = async (event) => {
    const bodyJson = event.body;
    const { firstName, lastName } = JSON.parse(bodyJson);
    const tableName = process.env.TABLE_NAME;
    console.log(firstName);
    console.log(lastName);

    const params = {
        TableName: tableName,
        Item: {
            id: new Date().getTime().toString(),
            firstName: firstName,
            lastName: lastName
        }
    };

    try {
        await client.send(new PutCommand(params));
        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Utilisateur ajouté avec succès' })
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Erreur lors de l\'ajout de l\'utilisateur' })
        };
    }
};
