#include <stdio.h>

char *flag = "旗RM7RF4o2";
char *dummy_flag = "Hint: you should be careful encoding of the flag";

int main(int argc, char *argv[])
{
    if (argv[1] == NULL) {
        fputs("Usage: ./q10 flag\n", stdout);
        return 1;
    }

    if (strcmp(argv[1], flag) == 0) {
        fputs("correct\n", stdout);
    } else {
        fputs("wrong\n", stdout);
    }

    return 0;
}
