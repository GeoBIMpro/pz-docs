# User Services

Piazza allows users to discover, manage, and invoke external web services that are referred to as *User Services*. A web service is a function that can be accessed over the web using HTTP. Web technologies such as HTTP, JSON, and XML (Extensible Markup Language) are used when creating web services because they allow for data to be exchanged in a platform-independent manner.

Piazza users can combine user services to perform complex tasks automatically such as orthorectifying an image, running statistical analysis on the image, and then notifying an analyst that the image has finished processing and is ready for review.

Piazza provides a REST API, allowing users to perform such user service management activities as:

1.  Register user services in the Service Registry for search/discovery (see the <a target="_blank" href="index.html#search">Search</a> section for details)

2.  Update information on the user service (e.g., URL, name, version, and other metadata)

3.  Remove a user service from the registry

4.  View details about registered user services

5.  Invoke a registered user service to perform some sort of task

6.  Combine user services to perform various tasks (see the <a target="_blank" href="index.html#workflow_service">Workflow Service</a> section for details)

While Piazza’s overall goal is to provide users with the ability to register and use existing RESTful user services, there are some guidelines on writing user services to work best with Piazza. See the <a target="_blank" href="index.html#how_to_write_your_own_user_services">How to Write Your Own User Services</a> section for details on how to write for discovery and user from within Piazza.

## Types of User Services

Piazza recognizes that there are two types of User Services: Synchronous Web Services and Asynchronous Web Services.

Synchronous Web Services, when invoked by a client, require the client to wait (or block) until a response and/or results are returned before the client can proceed with additional work. The figure below illustrates an example of Synchronous Web Services.

![Synchronous](images/PZ-service-sync.png)

Sometimes, however, the request submitted by the client may take a while to process or processing may be delayed. In cases such as this, it is beneficial to allow the client to continue working on other tasks while the user service processes the submitted request.

To support this need, Piazza provides support for Asynchronous User Services. With these types of services, clients are not blocked while waiting for a response. See the <a target="_blank" href="index.html#how_to_write_your_own_user_services">How to Write Your Own User Services</a> and the <a target="_blank" href="index.html#building_in_asynchronous_support">Building in Asynchronous Support</a> sections for details on how to write asynchronous user services.

![Asynchronous](images/PZ-service-async.png)

> **Note**
>
> Piazza currently requires that you have the user service instance deployed at a public URL. In the future, the user service will be a deployable container (or jar file) so Piazza can scale the number of instances needed. The following sections will use a *Hello World* service. This service responds with “hello” when invoked. It is deployed in our cloud for testing services.

## Registration

A user service must be registered within the Piazza Service Registry before it can be discovered or used by Piazza users.

To register a user service with Piazza, the client sends a JSON payload with the URL of the service, a description of its parameters, and other metadata to Piazza.

The `isAsynchronous` field is used to indicate whether a user service is an asynchronous user service. This value is a boolean and should be set to `true` if the user service supports the required Piazza endpoints for asynchronous processing. This field can be set to `false`, or omitted, if the user service does not intend to implement the asynchronous endpoints and upon invocation will instead return the results synchronously.

### Hello Example service registered with `GET` method

The service is registered by performing a `POST` request to the `/service` endpoint.

    {
        "url": "http://pzsvc-hello.venicegeo.io/",
        "contracturl": "http://helloContract",
        "method" : "GET",
        "isAsynchronous" : "false",
        "resourceMetadata": {
            "name": "pzsvc-hello service",
            "description": "Hello World Example",
            "classType": {
                "classification": "UNCLASSIFIED"
             }
        }
    }

-   <a target="_blank" href="https://pz-gateway.venicegeo.io/service">https://pz-gateway.venicegeo.io/service</a> is the endpoint for registering the user service with the following required JSON attributes:

    -   The `url` field is the URL for invoking the service. This is the *Root URL* for the service.
        
    -   The `contracturl` field contains additional detail information about the service.

    -   The `method` field is used to indicate the desired action to be performed on the service. (`GET`, `POST`, `PUT`, `DELETE`, etc.)

    -   The `isAsynchronous` flag is used to indicate whether the service is an asynchronous user service and implements the asynchronous endpoints.

    -   The `resourceMetadata` field has three subfields with the name, description of the service, and the Class Type for the service:

        -   The `name` field is used to identify the name of the service.

        -   The `description` field is used to describe the service.

        -   The `classType` field is used to indicate the classification of the registered service.

> **Note**
>
> The description should be entered with some care because it will
> enable other users to search for your service.

Successfully registering a service will return JSON of the following schema:

    {
        "type": "service-id",
        “data” : {
           "serviceId": "a04e274c-f929-4507-9174-dd24722d89d9"
        }
    }

The `serviceId` field should be noted since it will be used to invoke the service.

An example script for registering the "Hello World" service and returning the `serviceId` can be found at <a target="_blank" href="scripts/register-service.sh">register-service.sh</a>. Run it in the following way:

    $ ./register-service.sh

## Invocation

Once a user service is registered within Piazza, it can be invoked by sending a `POST` request to the Piazza API job endpoint `https://pz-gateway.venicegeo.io/job`. The `url` parameter in service registration, along with the `method` parameter, will constitute the execution endpoint. URL query parameters and/or the input being sent into the service are specified in the `dataInputs` field.

For details on how to invoke a user service, see <a target="_blank" href="http://pz-swagger.venicegeo.io/#!/Service/executeServiceUsingPOST">Piazza Swagger API</a>.

Piazza users invoking a user service will get a job response JSON payload response in the following format: 

	{ 
		"type":"job",
		"data":
		{ 
			"jobId”:”z42a2ea3-2e16-4ee2-bf74-fa7c792d1247" 
		} 
	} 

The `jobId` field contains a unique identifier of the specific running instance of the user service. This ID is used in subsequent requests to obtain the status of the job and to perform other job management capabilities.

### Hello Example service invoked with `GET` method

A script that does this can be found at <a target="_blank" href="scripts/execute-service.sh">execute-service.sh</a>. Provide the `serviceId` returned by the register script as the first argument to the script:

    $ ./execute-service.sh {{serviceId}}

    {
        "type": "execute-service",
        "data": {
            "serviceId": "a04e274c-f929-4507-9174-dd24722d89d9",
            "dataInputs": { },
            "dataOutput": [{ "mimeType":"application/json", "type":"text" }]
        }
    }

The `serviceId` is set to the return value from registering the service. In this example, no `dataInputs` are specified because there are no required parameters or payloads to invoke this service.

For details on the various ways to specify Data Inputs into the service, see <a target="_blank" href="https://pz-swagger.venicegeo.io/#!/Service/executeServiceUsingPOST">Invoking a service, POST Job</a> in Swagger for details.

For `dataOutput`, the `mimeType` refers to the actual Multipurpose Internet Mail Extensions (MIME) type(s) of the service output. The type refers to how the output will be stored until retrieved (see below). The return value is not the result of the service call. The execute-service call creates a job and returns the Job ID of that job.

`dataOutput` is specified as an array to allow for cases in which a user service will return multiple items from the service. For example, a given user service may return a JSON payload along with storing a generated raster image somewhere in a shared S3 bucket.

    {
        "type": "job",
        "data" :
                 {"jobId": "e42a2ea3-2f16-4ee2-bf74-fa7c792c0847"}
    }

### Hello Example service invoked with `POST` method

When invoking a service that requires a POST body for input, the body message is specified in the content field — the `type` is `"body"` and the `mimeType` has to be specified. Getting the `jobId` is exactly the same as with the `GET` request.

    {
        "type": "execute-service",
        "data": {
            "serviceId": "{{serviceId}}",
            "dataInputs": {
                "test" : {
                    "content" : "{ \"name\": \"Fred\", \"count\": 4 }",
                    "type" : "body",
                    "mimeType" : "application/json"
                }
            },
            "dataOutput": [{ "mimeType":"application/json", "type":"text" }]
        }
    }

### Getting the Status and Results of an Invocation

The status of a user service invocation is returned by sending a `GET` request to `https://pz-gateway.venicegeo.io/job/{{jobId}}` where `jobId` is the ID returned when executing the service. Piazza users should call this endpoint to determine the status of a running service.

## Status Details 
The granularity of the status provided depends on the type of user service that has been invoked. For synchronous user services, the status returned may be in the following format:

	{ 
		“data” : 
		{ 
			"status":"Running" 
		} 
	}

The acceptable statuses are as follows: `Pending`, `Running`, `Success`, `Cancelled`, `Error`, `Fail`.

For details on status reporting for asynchronous services, see the <a target="_blank" href="index.html#building_in_asynchronous_support">Building Asynchronous Support</a> section to see the various types of statuses that can be returned.

## Getting the Results

Once the user service has finished executing, the resulting data can be accessed by the Piazza user. Using the provided Data ID, users can retrieve the data results by sending a `GET` to the Piazza API data endpoint. For details on using this endpoint, see the <a target="_blank" href="http://pz-swagger.venicegeo.io/#!/Data/getMetadataUsingGET">Piazza API</a>.

The example below shows an example of job response depicting a successful execution.

    {
        "type": "status",
        "data": {
            "jobId": "e42a2ea3-2f16-4ee2-bf74-fa7c792c0847",
            "result": {
                "type": "data",
                "dataId": "b92e7cc5-310e-4a72-a4ab-21661b58d601"
            },
            "status": "Success",
            "jobType": "ExecuteServiceJob",
            "createdBy": "{{PZUSER}}",
            "progress": {}
        }
    }

A script that checks the status of the job can be found at <a target="_blank" href="scripts/get-job-info.sh">get-job-info.sh</a>. The script takes the `jobId` returned from the `execute-service.sh` script as its only argument:

    $ ./get-job-info.sh {{jobId}}

Finally, the actual result is returned by sending a `GET` request to `https://pz-gateway.venicegeo.io/data/{{dataId}}` where the `dataId` is from the `result.data.dataId` field of the returned status. In this case, the result is text.

    {
        "type": "data",
        "data": {
            "dataId": "b92e7cc5-310e-4a72-a4ab-21661b58d601",
            "dataType": {
                "content": "Hi. I'm pzsvc-hello.",
                "type": "text"
            }
            "metadata": {
                ...
            }
        }
    }

Run the <a target="_blank" href="scripts/get-data-info.sh">get-data-info.sh</a> script to check the result of the previous job. This script also takes a single argument: the `dataId` returned by the previous script:

    $ ./get-data-info.sh {{dataId}}

## Cancelling an Invocation

During execution of a Piazza job, the Piazza user who invoked a user service may also request to cancel or abort that job. Using the `jobId` that was provided from the invocation, a user can cancel a job using the `DELETE` method on the `https://pz-gateway.venicegeo.io/job/{{jobId}}` endpoint. For more details on how to use this, see the <a target="_blank" href="http://pz-swagger.venicegeo.io/#!/Job/abortJobUsingDELETE">Piazza API Abort Job</a>.

## Other Examples

For more examples on how to register and execute your service, see the <a target="_blank" href="/devguide/index.html">Piazza Developer’s Guide</a>.

## How to Write Your Own User Services

User Services are external web services that service developers write to be utilized by various users. When these services are registered within Piazza’s Service Registry, they can be discovered and invoked by any Piazza user. For example, suppose a developer has created an algorithm that does processing of point cloud data and wants to share it with others to use. He or she would create a user service and then register it with Piazza so that others may use it. Once a user service is registered with Piazza, Piazza users will be able to discover and invoke it to support the workflow in the applications that need it.

If a registered user service has additional security and access requirements (e.g., client certificate required, pre-authorization to use, etc.), users should contact the user service provider to negotiate access for use.

The contact information for each user service is located in the `resourceMetadata` field of the service payload. For details on the fields available when registering a user service, see the <a target="_blank" href="http://pz-swagger.venicegeo.io/#!/Service/registerServiceUsingPOST">Piazza API User Service Registration</a> for details.

## Designing Your User Service

When designing your user service, it should be written as a RESTful web service. REST is an architectural concept for creating client/server networked applications, and clients and servers exchange data using a stateless communication protocol such as HTTP.

### Establishing an API

To establish an API for exchanging data to and from your user service, consider using the JSON standard because data payloads are smaller, are easy to read, and work programmatically (e.g. using JavaScript).

XML is also used to exchange data with RESTful web services. With XML, data is very structured and is stored in a markup language that is readable. As a result of the formatting, XML payloads are much larger than JSON payloads. With this approach, calling RESTful web services is typically done by sending in URL parameters to the service with responses from the service in an XML format. When using XML, a well-documented schema should be used to validate and to describe the responses that may be sent from your service.

For guidance on best practices when creating the RESTful API to your web service, see the <a target="_blank" href="https://github.com/18F/api-standards">18F API standard</a> for details.

## Implementing Scalability

*Scalability* needs to be considered when developing a user service. Scalability is the ability of your user service to handle a growing amount of requests or work to meet the business or mission needs. There are two types of scaling that needs to be considered:

-   *Vertical Scalability* 

	Achieved by adding or removing resources to a single machine, virtual machine, or node to support changes in the workload or user requests. Example resources include CPUs or memory.

-   *Horizontal Scalability*

	Achieved by adding or removing machines, virtual machines, or nodes to support changes in the workload or user requests. Typically, a load-balancer is used to distribute multiple requests across many machines.

The figure below shows an example of each of these types of scalability approaches.

![Scalability](images/PZ-scalability.png)

Even though these are typical approaches for implementing scalability, sometimes these approaches are not accessible for various reasons. It might cost too much to allocate multiple resources or to obtain a larger EC2 instance. Also, the user service itself might not be architected to handle multiple requests or requests containing large datasets. It might be able to handle multiple user requests concurrently but then have bottlenecks as it tries to process data.

For this reason, Piazza has implemented *Task Management* to support user services that are new, are being implemented iteratively, or are just are not ready to handle large amounts of service invocations. Task Management allows user service developers to poll Piazza for work instead of taking service invocations directly from Piazza. The next section discusses how to incorporate task management within your user service.

## Task Management

Task Management is a capability that allows user service developers to *poll* for work instead of being invoked directly by Piazza. To tell Piazza that you are task-managed service, you must register your service by setting the `isTaskManaged` attribute to `true`. Below is an example JSON payload for using the `isTaskManaged` attribute with the other required fields necessary during registration.

    {
        "url": "http://pzsvc-hello.venicegeo.io/",
        "contractUrl": "http://helloContract",
        "method" : "GET",
        "isTaskManaged" : "true",
            "taskAdministrators" : ["UserNameA", "UserNameB"],
            "timeout" : 500,
        "resourceMetadata": {
            "name": "pzsvc-hello service",
            "description": "Hello World Example",
            "classType": {
                "classification": "UNCLASSIFIED"
             }
        }
    }

The `taskAdministrators` array is used to specify the list of Piazza user names that will have access to this service’s queue. Only these user names will be able to poll for work and process jobs. Additionally, the `timeout` can be optionally specified in order to tell Piazza how many seconds to let pass before assuming a single job for this service has timed out.

Note that a service that `isTaskManaged` does not communicate directly with the external service in any way. As such, the `url` field in the service registration payload does not necessarily need to represent a functional endpoint for the service. Additionally, the `isAsynchronous` field is ignored when `isTaskManaged` is set to true.

### Polling for Work

Once your user service is registered as a Task Managed service, Piazza will not invoke the user service directly. Instead, your user service should poll Piazza for jobs to work on by submitting a `POST` to `https://pz-gateway.venicegeo.io/service/{{serviceId}}/task`. The `serviceId` is the `serviceId` that was returned when you registered your user service. If your service has any pending job executions, then a single job will be returning from that POST. It will contain the `data.serviceData` field that is the exact inputs the user sent to invoke the user service. It also contains the `data.jobId` field that will later be used to tell Piazza any updates for the status/results of the job. If no jobs are in your queue, those fields will be `null`.

## Sending Status Updates for the Job

When you need to send Piazza status updates or results for the job your user service is working on, submit a `POST` to `https://pz-gateway.venicegeo.io/service/{{serviceId}}/task/{{jobId}}`. The payload for this POST is a status update object, which is the exact same model that you previously used in asynchronous services. For details on this model, see the <a target="_blank" href="index.html#status_details">Status Details</a> section.

For example, if your user service failed to execute, the payload that would be sent to Piazza would be:

	{ "status”:"Fail" }

If your user service completed executing and has results, the payload that would be sent back to Piazza would be: 

	{ 
		"status" : "Success", 
		"result" : 
		{ 
			"type" : "data", 
			"dataId" : "data\_id\_here" 
		} 
	}

Metadata about your user service’s jobs queue can be obtained by submitting a `GET` to `https://pz-gateway.venicegeo.io/service/{{serviceId}}/task/metadata`. The response will show the number of jobs in your user service’s jobs queue.

## Timeouts in Task Managed Services

Optionally, the `timeout` parameter can be specified upon initial service registration. If specified, Piazza will then periodically check for jobs that have been pulled from the service queue that have exceeded the duration of this timeout period. For example, if a service specifies its timeout as five minutes long and a job runs for more than five minutes, Piazza Task Management will consider this specific job as *timed out*. When a task-managed job times out, it will be placed back in the service queue and is available to be polled again by another worker. If that specific service job fails two more subsequent times, then it will be removed from the queue entirely and flagged as a failure by Piazza.

### Building in Asynchronous Support

If you anticipate that your user service will be doing time-consuming activities, then consider making it an asynchronous user service. To provide for this functionality, Piazza recommends that the following set of functions and behaviors be incorporated into your user service. The following sections steps through each of these items.

### Service Invocation Response

For Piazza to track and work with your asynchronous service, a unique identifier, or Job ID needs to be generated and returned to Piazza when the service is invoked.

![Invocation](images/PZ-async-user-service.png)

The "url" parameter in service registration, along with the "method" parameter, will constitute the invocation endpoint. This URL will be called directly with the specified HTTP method, and will be expected to return a JSON payload with the following format:

	{
		"type":"job",
		"data":
		{
			"jobId":"123456"
		}
	}

In the example above, Piazza will use the Job ID value of *123456* as the ID for tracking your user service execution instance.

The image below shows details on the interaction between Piazza and the user service during service invocation.

![Asynchronous](images/PZ-async-invoke.png)

### Status Endpoint

For Piazza to be able to query the status of your user service, a status endpoint has to be implemented. The endpoint `/status/{jobId}` and path variable need to be added to the root URL of the service with support of the HTTP GET method.

For example, if the root URL is `http://service/analysis`, then Piazza will infer the status URL as HTTP `GET` `http://service/analysis/status/{jobId}`.

Once an instance of your user service has been started (by Piazza calling the invocation endpoint), Piazza will periodically call the status endpoint in order to determine the current progress of this instance. This includes the status of the service and any progress information.

The figure below shows the interaction between Piazza and your user
service.

![Asynchronous Status](images/PZ-async-status.png)

Your status endpoint should respond with the following JSON payloads.

For example: 

	{ 
		"status":"Running" 
	} 

The acceptable statuses are as follows: `Pending`, `Running`, `Success`, `Cancelled`, `Error`, and `Fail`. You can also include a `progress` field that is able to contain a percentage completion for the job: 

	{ 
		"status":"Running", 
		"progress" : 
		{ 
			"percentComplete": 80 
		} 
	} 
 
As the services continue to process results, it should update the status as needed. When your user service has completed, then it should set the status to `Success.` Piazza, upon seeing this, will then initiate a request to the results endpoint in order to fetch the results of this instance when ready.

On `Error`, the status endpoint will also report error information. If your service encounters an error during execution, it can report this back in the status response:

	{ 
		"status":"Error", 
		"result" : 
		{ 
			"type": "error", 
			"message": "Things went wrong.", 
			"details": "Perhaps a Stack Trace here." 
		} 
	}

The `result` field can define a message and details property that can be used to convey error information back to the Piazza user who initiated this instance of the user service. Once Piazza encounters an error status, it will cease to poll for status and it will not attempt to query the results endpoint.

## Result

When your user service reports back a `Success` status, then Piazza will initiate a subsequent call to the results endpoint. The results URL will be extended from your root URL by adding a `/result/{jobId}` endpoint and path variable.

For example, if the root URL is `http://service/analysis`, then Piazza will infer the results URL as HTTP `GET` `http://service/analysis/result/{jobId}`. The return value for this response should be identical to the return value from the execution endpoint of a traditional synchronous user service.

When Piazza initiates a successful call to the results endpoint of a service, it should be considered a guarantee that Piazza will make no further queries related to that execution instance.

## Cancellation

During execution of a Piazza job, the user who requested that job execution may also request to terminate that job. In this case, Piazza will use the cancellation endpoint of an asynchronous user service in order to notify that any work related to that specific instance should be terminated, and no subsequent calls will be made related to that instance. The cancellation URL will be extended from the root URL by adding a `/job/{jobId}` endpoint and path variable.

For example, if the root URL is `http://service/analysis`, then Piazza will infer the cancellation URL as HTTP `GET` `http://service/analysis/job/{jobId}`.

The ID of the instance can be used internally by the user service to clean up any resources related to that instance. It can be considered a guarantee by Piazza that no subsequent calls will be made related to that instance.

## Output From Your User Service

Piazza supports a number of output formats generated from user services registered within Piazza. User services should generate a Piazza DataResource JSON payload as output conforming to defined Piazza DataTypes defined within Piazza. For example, if the user service generates plain text as an output format, the JSON payload that should be returned from the user service should be a DataResource with the `dataType.type` field set to `text`.

Piazza does not store data such as raster images, large GeoJSON payloads, etc., so Piazza users should leverage the Piazza DataResource payloads to indicate where output data is stored after it is generated from the user service.

For example, if a user service generates a raster image, the output from the service would be in a JSON payload format similar to the JSON payload below:

    {
        "dataType": {
            "type": "raster",
            "location": {
                "type": "s3",
                "bucketName": "pz-svcs-prevgen-output",
                "fileName": "478788dc-ac85-4a85-a75c-cbb352620667-NASA-GDEM-10km-colorized.tif",
                "domainName": "s3.amazonaws.com"
            },
            "mimeType": "image/tiff"
        },
        "metadata": {
            "name": "External Crop Raster Service",
            "id": "478788dc-ac85-4a85-a75c-cbb352620667-NASA-GDEM-10km-colorized.tif",
            "description": "service that takes payload containing s3 location and bounding box for some raster file, downloads, crops, and uploads the crop back up to s3.",
            "url": "http://host:8086/crop",
            "method": "POST"
        }
    }

This output format is a DataResource payload that indicates the location of a cropped raster image Amazon Web Service (AWS) Simple Storage Service (S3) directory. Metadata about the user service that generated the image along with other data is indicated in the `metadata` field of the payload. The `mimeType` field indicates the type of raster image that was generated.

When generating a DataResource payload, `type` and `mimeType` are required for all DataTypes. Additional fields are required depending on the type of data that is generated from the user service.

For details on the DataResource payload and the available DataTypes, see the <a target="_blank" href="http://pz-swagger.venicegeo.io/#!/Data/getMetadataUsingGET">Piazza Data API</a>.

### What to do About Existing Services

If you have an existing service, consider following the <a target="_blank" href="https://github.com/18F/api-standards">18F API standard</a> for guidance on best practices. For existing services that are not RESTful, consider wrapping these services with a REST representation. For example, the first generation of web services included heavyweight approaches such as Simple Object Access Protocol (SOAP), where messages were transmitted using XML over HTTP. If converting the service to a REST representation is not possible for services such as these, then consider wrapping these services.

## Putting Your User Service into Action within Piazza

## Registering Your User Service

When registering your service, provide enough metadata about your service so it can be searched and discovered using Piazza’s search capability.

For details on the fields available when registering a user service, see the <a target="_blank" href="http://pz-swagger.venicegeo.io/#!/Service/registerServiceUsingPOST">Piazza API User Service Registration</a> for details.

When registering a service, the following fields are required:

1.  `url`

2.  `method`

3.  `contractUrl`

4.  `isAsynchronous`

5.  `resourceMetadata.name`

6.  `resourceMetadata.description`

7.  `resourceMetadata.classType`

## Availability of Your User Service

User services registered within Piazza have an `availability` field that indicates the status/health of the service. Services can have an availability value of `ONLINE`, `OFFLINE`, `DEGRADED`, and `FAILED`. When your user service is initially registered with Piazza, the status of that service is automatically set to `ONLINE` within the Piazza Service Registry.

Below is an example of the payload to send to update your service’s status:

    {
      "resourceMetadata" : {
        "availability" : "OFFLINE"
      }
    }

Piazza continually monitors the health of user services registered in the service registry. Piazza continually monitors these user services and when response time from these services starts to be slow, Piazza may set the status of a registered user service, to `DEGRADED`. If the user service is unresponsive over a period of time, the status of the user service may be changed to `FAILED`.

### Service API Documentation

See <a target="_blank" href="http://pz-swagger.venicegeo.io/#/service">http://pz-swagger.venicegeo.io/#/service</a> for the complete User Service API.
