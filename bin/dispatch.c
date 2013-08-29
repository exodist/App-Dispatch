#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

int main(int argc, char* argv[]) {
    execvp( "dispatch.pl", argv );
    printf( "Could not exec 'dispatch.pl': %s\n", strerror(errno) );
    exit(errno);
}

