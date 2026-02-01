# Use local kubernetes deployment for learning blue-green

## Objective 
Learn blue-green deployment using local kubernetes deployment .
Principle objective is for educational purpose .

## Tools
Tool to be used kind for k8s cluster deployment.

## Application 
Application used will be simple application .
Consisting of 
 * Backend application - python 
   This application will have one end point /calculate . it will have one input amount
   Response will be double the input amount .
 * Database - Simplest database which can be deployed using kind and for further    application extensions. 
 * IDP - simple IDP like Keycloak will do. If there is simpler than Keycloak, can be used
 * Load balancer - nginx
 * frontend - pure html . Login screen , followed by compute screen , which will consume calculate api 
 * Application should have semantic versioning 
 * Application to be deployed in local k8s cluster using kind.

## Flow of the application
 * user id is created in IDP 
 * user login is done through login screen . validate user with IDP 
 * if yes , open compute screen , click on compute 

## Blue-green 
  * Want to deploy new version of the application in blue-green fashion 
  ### New application version
    * new version of the application will modify the /calculate endpoint with additional argument ( non mandatory)
    * Additional argument will be discount .
    * /calculate will reduce the discount from computed amount.
  * We need to have ability to have test cases for blue version ,before you find that blue instance is working.
  * Ability to have status page on blue-green deployment and monitor blue-green deployment. 



