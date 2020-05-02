#include "../socketChat.h"

void *thread_function(void *arg);



int acceptnum = 0;

void newAcceptT(int client_sockfd)
{
    int res;
    pthread_t a_thread;
    pthread_attr_t thread_attr;

    res = pthread_attr_init(&thread_attr);
    if (res != 0)
    {
        perror("Attribute creation failed\n");
        exit(EXIT_FAILURE);
    }
    res = pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
    if (res != 0)
    {
        perror("Setting detached attribute failed\n");
        exit(EXIT_FAILURE);
    }
    res = pthread_create(&a_thread, &thread_attr, thread_function, (void *)client_sockfd);
    if (res != 0)
    {
        perror("Thread creation failed\n");
        exit(EXIT_FAILURE);
    }
}

void *exitfunction(void *arg)
{
    int i = 1;
    printf("exit: enter 0\n");
    while (i)
        scanf("%d", &i);
    exit(0);
}

int main()
{
    int server_sockfd, client_sockfd;
    int server_len, client_len;
    struct sockaddr_in server_address;
    struct sockaddr_in client_address;

    server_sockfd = socket(AF_INET, SOCK_STREAM, 0);

    /* bind the socket to the certain port number 2760 */
    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = htonl(INADDR_ANY);
    server_address.sin_port = htons(2760);
    server_len = sizeof(server_address);
    bind(server_sockfd, (struct sockaddr *)&server_address, server_len);
    
    /*  Create a connection queue, ignore child exit details and wait for clients.  */
    listen(server_sockfd, 5);

    /* create the thread to read the input and exit the server program */
    int res;
    pthread_t killthread;
    res = pthread_create(&killthread, NULL, exitfunction, (void *)0);
    if (res != 0)
    {
        perror("Thread creation failed\n");
        exit(EXIT_FAILURE);
    }

    while (1) //main loop
    {

        printf("server waiting\n");
        /*  Accept connection.  */
        client_len = sizeof(client_address);
        client_sockfd = accept(server_sockfd,
                               (struct sockaddr *)&client_address, &client_len);
        printf("accept num = %d\n", acceptnum++);
        newAcceptT(client_sockfd); // create a new thread in another function, and pass the sockfd
    }
    exit(EXIT_SUCCESS);
}

void clientMessage(int fd, char *cause, char *errnum,
                   char *shortmsg)
{
    char buf[BUFFER_SIZE], body[BUFFER_SIZE];
    body[0] = 0;
    /* Build the HTTP response body */
    if (!strcmp(errnum, "200"))
        sprintf(body, "<html><body>%s</body></html>", shortmsg);

    /* Print the HTTP response */
    sprintf(buf, "HTTP/1.0 %s %s\r\n", errnum, shortmsg);
    Rio_writen(fd, buf, strlen(buf));
    printf("%s", buf);
    sprintf(buf, "Content-type: text/html\r\n");
    Rio_writen(fd, buf, strlen(buf));
    printf("%s", buf);
    sprintf(buf, "Content-length: %d\r\n\r\n", (int)strlen(body));
    Rio_writen(fd, buf, strlen(buf));
    printf("%s", buf);
    Rio_writen(fd, body, strlen(body));
}

void read_requestdrs(int sockfd)
{
    char buffer[BUFFER_SIZE];
    readlineb(sockfd, buffer, BUFFER_SIZE);
    printf("%s", buffer);
    while (strcmp(buffer, "\r\n"))
    { 
        readlineb(sockfd, buffer, BUFFER_SIZE);
        printf("%s", buffer);
    }
}

int parse_uri(char *uri, char *filename, char *cgiargs)
{
    strcpy(cgiargs, "");               
    strcpy(filename, "../serverfolder");        
    strcat(filename, uri);            
    if (uri[strlen(uri) - 1] == '/')   
        strcat(filename, "test.html"); 
    return 1;
}

void get_filetype(char *filename, char *filetype)
{
    if (strstr(filename, ".html"))
        strcpy(filetype, "text/html");
    else if (strstr(filename, ".gif"))
        strcpy(filetype, "image/gif");
    else if (strstr(filename, ".png"))
        strcpy(filetype, "image/png");
    else if (strstr(filename, ".jpg"))
        strcpy(filetype, "image/jpeg");
    else
        strcpy(filetype, "text/plain");
}

void sendAns(int fd, char *filename, int filesize)
{
    int srcfd;
    char *srcp, filetype[BUFFER_SIZE], buf[BUFFER_SIZE];

    /* Send response headers to client */
    get_filetype(filename, filetype);    
    sprintf(buf, "HTTP/1.0 200 OK\r\n"); 
    sprintf(buf, "%sServer: A Web Server\r\n", buf);
    sprintf(buf, "%sConnection: close\r\n", buf);
    sprintf(buf, "%sContent-length: %d\r\n", buf, filesize);
    sprintf(buf, "%sContent-type: %s\r\n\r\n", buf, filetype);
    Rio_writen(fd, buf, strlen(buf)); 
    printf("Response headers:\n");
    printf("%s", buf);

    /* Send response body to client */
    srcfd = open(filename, O_RDONLY, 0);                       
    srcp = mmap(0, filesize, PROT_READ, MAP_PRIVATE, srcfd, 0); 
    close(srcfd);                                               
    Rio_writen(fd, srcp, filesize);                             
    munmap(srcp, filesize);                                     
}

void *thread_function(void *arg)
{
    int sockfd = (int)arg;
    printf("thread_function is running. client_sockfd was %d\n", sockfd);
    // preapre
    struct stat sbuf;
    char buffer[BUFFER_SIZE], method[BUFFER_SIZE], uri[BUFFER_SIZE], version[BUFFER_SIZE];
    char filename[BUFFER_SIZE], cgiargs[BUFFER_SIZE];

    /* read the first line of http message */
    if (!readlineb(sockfd, buffer, BUFFER_SIZE)) // read one line from the socket
    {
        perror("Reading first line failed\n");
        pthread_exit(NULL);
    }
    printf("%s", buffer);
    sscanf(buffer, "%s %s %s", method, uri, version); // get the method, uri and version infomation

    /* GET method */
    if (!strcasecmp(method, "GET")) 
    {
        read_requestdrs(sockfd);
        parse_uri(uri, filename, cgiargs); // process the uri for the filename
        if (stat(filename, &sbuf) < 0) // cannot find the file
        { 
            clientMessage(sockfd, filename, "404", "Not found");
            pthread_exit(NULL);
        }
        if (!(S_ISREG(sbuf.st_mode)) || !(S_IRUSR & sbuf.st_mode))
        { 
            clientMessage(sockfd, filename, "403", "Forbidden");
            pthread_exit(NULL);
        }
        sendAns(sockfd, filename, sbuf.st_size); //response
    }
    /* POST method */
    else if (!strcasecmp(method, "POST"))
    {
        if (strcmp(uri, "/dopost")) // if the uri is not /dopost
        {
            clientMessage(sockfd, filename, "404", "Not found");
            pthread_exit(NULL);
        }
        while (strstr(buffer, "Content-Length")==NULL) // find the line start with "Content-Length"
        { 
            readlineb(sockfd, buffer, BUFFER_SIZE);
            printf("%s", buffer);
        }
        int length;
        sscanf(buffer,"Content-Length: %d",&length); // get the length of the body
        read_requestdrs(sockfd);
        
        Rio_readn(sockfd,buffer,length); // read the body
        buffer[length]=0;
        printf("%s\n",buffer);
        if(!strcmp(buffer,"login=3180102760&pass=2760")) // compare the username and password
            clientMessage(sockfd, filename, "200", "login successfully");
        else
            clientMessage(sockfd, filename, "200", "login failed");
    }
    else
    {
        clientMessage(sockfd, method, "501", "Not Implemented");
        pthread_exit(NULL);
    }
    pthread_exit(NULL);
}
