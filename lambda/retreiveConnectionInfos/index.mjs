import AWS from "aws-sdk";

export const handler = async (event) => {
  const connectionId = event.requestContext.connectionId;
  const endpoint = `${event.requestContext.domainName}/${event.requestContext.stage}`
  const apigw = new AWS.ApiGatewayManagementApi({
    endpoint
  });

  console.log(endpoint)

  await apigw.postToConnection({
    ConnectionId: connectionId,
    Data: JSON.stringify({
      type: "CONNECTION_ACK",
      connectionId: connectionId
    })
  }).promise();

  return { statusCode: 200 };
};