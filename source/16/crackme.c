#include <stdio.h>
#include <string.h>
#include <openssl/sha.h>

// The flag is "gD0Fbs3642"
// SHA1: c5b55e1f6405b6c27800d7a3c80356d5c8f1b6b8

unsigned char trash[20] = {
    0xc5, 0xb5, 0x5e, 0x1f, 0x64, 0x05, 0xb6, 0xc2, 0x78, 0x00, 0xd7, 0xa3, 0xc8, 0x03, 0x56, 0xd5, 0xc8, 0xf1, 0xb6, 0xb8
};

int main(void)
{
    char input[10];
    char flag[16];
    unsigned char buf[20];
    int i;
    int n;

    fgets(input, sizeof(input), stdin);
    n = atoi(input);
    snprintf(flag, sizeof(flag), "gD0Fbs%d", n);

    SHA1(flag, 10, buf);

    for (i = 0; i < 20; i++) {
        if (buf[i] != trash[i]) {
            printf("wrong...\n");
            return 1;
        }
    }

    printf("the flag is: %s\n", flag);
    return 0;
}
