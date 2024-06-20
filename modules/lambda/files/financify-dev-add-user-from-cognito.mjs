import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { PutCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient();

export const handler = async (event) => {
    const userAttributes = event.request.userAttributes;
    const userId = userAttributes.sub;
    const email = userAttributes.email;
    const givenName = userAttributes.given_name
    const familyName = userAttributes.family_name
    const createdAt = new Date().toISOString();

    const params = {
        TableName: 'financify-dev-user',
        Item: {
            id: new Date().getTime().toString(),
            email: email,
            givenName: givenName,
            familyName: familyName,
            createdAt: createdAt
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
