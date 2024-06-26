import {DynamoDBClient, UpdateItemCommand} from "@aws-sdk/client-dynamodb";
import {
    CognitoIdentityProviderClient,
    AdminUpdateUserAttributesCommand
} from "@aws-sdk/client-cognito-identity-provider";

const dynamoClient = new DynamoDBClient({region: process.env.REGION});
const cognitoClient = new CognitoIdentityProviderClient({region: process.env.REGION});

const userPoolId = process.env.USER_POOL_ID

export const handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    for (const record of event.Records) {
        console.log('Processing record:', JSON.stringify(record, null, 2));
        if (record.eventName === 'MODIFY') {
            const newImage = record.dynamodb.NewImage;
            const oldImage = record.dynamodb.OldImage;

            console.log('NewImage fields:');
            Object.keys(newImage).forEach(key => {
                console.log(`${key}: ${JSON.stringify(newImage[key], null, 2)}`);
            });

            const userId = oldImage.id.S;
            const email = oldImage.email.S;
            const givenName = newImage.givenName.S;
            const familyName = newImage.familyName.S;

            try {
                const command = new AdminUpdateUserAttributesCommand({
                    UserPoolId: userPoolId,
                    Username: email,
                    UserAttributes: [
                        {Name: 'given_name', Value: givenName},
                        {Name: 'family_name', Value: familyName}
                    ]
                });

                const response = await cognitoClient.send(command);
                console.log(`Utilisateur ${userId} mis à jour avec succès dans Cognito.`, response);
            } catch (error) {
                console.error(`Erreur lors de la mise à jour de l'utilisateur ${userId} :`, error);
            }
        }
    }

    return {
        statusCode: 200,
        body: JSON.stringify('Traitement des événements terminé.')
    };
};
