import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { PutCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient();

export const handler = async (event) => {
    const bodyJson = event.body;
    const { name, amount, billingDay,  } = JSON.parse(bodyJson);
    const tableName = process.env.TABLE_NAME;
    console.log(firstName);
    console.log(lastName);

    const params = {
        TableName: tableName,
        Item: {
            id: new Date().getTime().toString(),
            nane: name,
            amount: amount,
            billingDay: billingDay
        }
    };

    try {
        await client.send(new PutCommand(params));
        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'La catégorie de dépense a été ajouté avec succès' })
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Erreur lors de l\'ajout de la catégorie de dépense' })
        };
    }
};
