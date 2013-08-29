#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

int main(int argc, char* argv[]) {
    char **newargv = malloc( argc + 1 );
    int i;
    for (i = 0; i < argc; i++) {
        newargv[i] = argv[i];
    }
    newargv[argc] = NULL;

    newargv[0] = "dispatch.pl";

    execvp( "dispatch.pl", newargv );

    printf( "Could not exec! %s\n", strerror(errno) );
    exit(errno);
}

