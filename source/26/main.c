#include <conio.h>

typedef unsigned char byte;

#define BTN_RIGHT   0x01
#define BTN_LEFT    0x02
#define BTN_DOWN    0x04
#define BTN_UP      0x08
#define BTN_START   0x10
#define BTN_SELECT  0x20
#define BTN_B       0x40
#define BTN_A       0x80

#define PORT_1_ADDR (byte *)0x4016
#define PORT_2_ADDR (byte *)0x4017

#define APUFLAGS (byte *)0x4015
#define SQ1_ENV  (byte *)0x4000
#define SQ1_LO   (byte *)0x4002
#define SQ1_HI   (byte *)0x4003

#define KEY_LEN 24

void check_pad(void);
byte btn_push(byte btn);
void sleep(unsigned int wait);
void play_se(byte lo);
void init_screen(void);
void draw_button_text(byte button, byte invert);
void draw_message(const byte *msg, byte x, byte mood);
void delete_text(void);
byte cstrlen(const byte *str);
byte build_key(byte i);
byte build_flag(byte i);
byte check_key(void);
void fill_current_pos(byte c);
void redraw_key(void);
void move_keyboard_cursor(byte i, byte cursor_type);
void remove_keyboard_cursor(void);
void move_button_cursor(byte x);
void remove_button_cursor(void);
void move_key_cursor(byte x);

byte char_table[4][13] = {
    {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-',  '=', '\\'},
    {' ', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',  '[',  ']'},
    {' ', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'',  ' '},
    {' ', ' ', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.',  '/',  ' '}
};

byte joypad[2];

byte pos = 0;
byte button_pos = 0;
byte keyboard_pos[2] = {};

byte key[KEY_LEN + 1] = {};
byte flag1[KEY_LEN] = {
    0x69, 0x73, 0x70, 0x6b, 0x62, 0x74, 0x62, 0x37, 0x6b, 0x7b, 0x7f, 0x3b, 0x65, 0x2d, 0x77, 0x6d, 0x0, 0x47, 0x12, 0x42, 0x50, 0x25, 0x26, 0x27
};

byte frame_h  = 0x0b;
byte frame_v  = 0x0e;
byte frame_lt = 0x14;
byte frame_rt = 0x12;
byte frame_lb = 0x11;
byte frame_rb = 0x08;

byte c_block   = 0xa0;
byte c_cursor  = '>';
byte c_removal = ' ';

void check_pad(void) {
    byte i;

    *PORT_1_ADDR = 1; // set
    *PORT_1_ADDR = 0; // clear

    joypad[1] = joypad[0];
    joypad[0] = 0;
    for (i = 0; i < 8; i++) {
        joypad[0] <<= 1;
        joypad[0] += (*PORT_1_ADDR & 0x01);
    }
}

byte btn_push(byte btn) {
    if ((joypad[0] & btn) && !(joypad[1] & btn)) {
        return 1;
    } else {
        return 0;
    }
}

void sleep(unsigned int wait) {
    unsigned int i;

    i = 0;
    while (i++ < wait);
}

// see also http://www.nintendoage.com/forum/messageview.cfm?catid=22&threadid=22484
void play_se(byte lo) {
    *APUFLAGS = 0x01; // enable SQ1
    *SQ1_ENV  = 0x3f; // Duty 01 (25%), Volume F

    *SQ1_LO = lo;
    *SQ1_HI = 0x00;

    // とりあえず ;(
    sleep(100);

    *SQ1_LO = 0x00;
    *SQ1_HI = 0x00;
}

void init_screen(void) {
    byte i;
    byte j;

    clrscr();


    gotoxy(9, 5);
    cprintf("retro  crackme");


    gotoxy(3, 7);
    cputc(frame_lt);
    for (i = 0; i < KEY_LEN; i++) {
        cputc(frame_h);
    }
    cputc(frame_rt);

    gotoxy(3, 8);
    cputc(frame_v);
    //cputc("looking for l0ve s0ng");
    gotoxy(28, 8);
    cputc(frame_v);

    gotoxy(3, 9);
    cputc(frame_lb);
    for (i = 0; i < KEY_LEN; i++) {
        cputc(frame_h);
    }
    cputc(frame_rb);


    gotoxy(1, 12);
    cputc(frame_lt);
    for (i = 0; i < 28; i++) {
        cputc(frame_h);
    }
    cputc(frame_rt);

    for (i = 0; i < 4; i++) {
        gotoxy(1, 13 + i);
        cputc(frame_v);
        for (j = 0; j < 13; j++) {
            gotoxy(4 + j * 2, 13 + i);
            cputc(char_table[i][j]);
        }
        gotoxy(30, 13 + i);
        cputc(frame_v);
    }

    gotoxy(1, 17);
    cputc(frame_lb);
    for (i = 0; i < 28; i++) {
        cputc(frame_h);
    }
    cputc(frame_rb);


    gotoxy(6, 18);
    cputc(frame_lt);
    for (i = 0; i < 4; i++) {
        cputc(frame_h);
    }
    cputc(frame_rt);
    cputc(frame_lt);
    for (i = 0; i < 7; i++) {
        cputc(frame_h);
    }
    cputc(frame_rt);
    cputc(frame_lt);
    for (i = 0; i < 3; i++) {
        cputc(frame_h);
    }
    cputc(frame_rt);
    cputc(frame_lt);
    for (i = 0; i < 3; i++) {
        cputc(frame_h);
    }
    cputc(frame_rt);
    gotoxy(6, 19);
    cputc(frame_v);
    draw_button_text(1, 0);
    cputc(frame_v);
    cputc(frame_v);
    draw_button_text(2, 0);
    cputc(frame_v);
    cputc(frame_v);
    draw_button_text(3, 0);
    cputc(frame_v);
    cputc(frame_v);
    draw_button_text(4, 0);
    cputc(frame_v);
    gotoxy(30, 19);
    cputc(frame_v);
    gotoxy(6, 20);
    cputc(frame_lb);
    for (i = 0; i < 4; i++) {
        cputc(frame_h);
    }
    cputc(frame_rb);
    cputc(frame_lb);
    for (i = 0; i < 7; i++) {
        cputc(frame_h);
    }
    cputc(frame_rb);
    cputc(frame_lb);
    for (i = 0; i < 3; i++) {
        cputc(frame_h);
    }
    cputc(frame_rb);
    cputc(frame_lb);
    for (i = 0; i < 3; i++) {
        cputc(frame_h);
    }
    cputc(frame_rb);

    move_key_cursor(0);
    move_keyboard_cursor(0, 0);
}

void draw_button_text(byte button, byte invert) {
    switch (button) {
    case 1:
        gotoxy(7, 19);
        if (invert) {
            cprintf("\302\301\303\313");
        } else {
            cprintf("BACK");
        }
        break;
    case 2:
        gotoxy(13, 19);
        if (invert) {
            cprintf("\306\317\322\327\301\322\304");
        } else {
            cprintf("FORWARD");
        }
        break;
    case 3:
        gotoxy(22, 19);
        if (invert) {
            cprintf("\304\305\314");
        } else {
            cprintf("DEL");
        }
        break;
    case 4:
        gotoxy(27, 19);
        if (invert) {
            cprintf("\305\316\304");
        } else {
            cprintf("END");
        }
        break;
    }
}

// msg: 16 characters or less
void draw_message(const byte *msg, byte x, byte mood) {
    byte i;

    gotoxy(8, 14);
    for (i = 0; i < x; i++) {
        cputc(c_block);
        sleep(255);
    }
    for (; *msg != '\0' && i < 16; *msg++, i++) {
        cputc(*msg + 0x80);
        if (mood) {
            play_se(0xf9);
            play_se(0x8a);
            sleep(500);
        } else {
            play_se(0xc9);
            play_se(0xba);
        }
    }
    for (; i < 16; i++) {
        cputc(c_block);
        sleep(255);
    }
}

void delete_text(void) {
    byte i;

    for (i = pos; i < KEY_LEN; i++) {
        if (key[i] != '\0') {
            key[i] = '\0';
        } else {
            break;
        }
    }
    if (i > pos) {
        play_se(0xff);
        move_key_cursor(0);
    }
}

byte cstrlen(const byte *str) {
    byte len;

    for (len = 0; *str != '\0'; *str++, len++);
    return len;
}

byte build_key(byte i) {
    if (key[i] >= 'A' && key[i] <= 'Z') {
        return 'A' + (key[i] - 'A' + 13) % 26;
    } else if (key[i] >= 'a' && key[i] <= 'z') {
        return 'a' + (key[i] - 'a' + 13) % 26;
    } else {
        return key[i];
    }
}

byte build_flag(byte i) {
    return flag1[i] ^ (16 + i);
}

byte check_key(void) {
    byte i;

    if (cstrlen(key) != 21) {
        return 0;
    }
    for (i = 0; i < KEY_LEN; i++) {
        if (build_key(i) != build_flag(i)) {
            return 0;
        }
    }
    return 1;
}

void move_keyboard_cursor(byte x, byte y) {
    gotoxy(3 + keyboard_pos[0], 13 + keyboard_pos[1]);
    cputc(c_removal);
    keyboard_pos[0] += x;
    keyboard_pos[1] += y;
    gotoxy(3 + keyboard_pos[0], 13 + keyboard_pos[1]);
    cputc(c_cursor);
}

void remove_keyboard_cursor(void) {
    gotoxy(3 + keyboard_pos[0], 13 + keyboard_pos[1]);
    cputc(c_removal);
}

void move_button_cursor(byte x) {
    draw_button_text(button_pos, 0);
    button_pos += x;
    draw_button_text(button_pos, 1);
}

void remove_button_cursor(void) {
    draw_button_text(button_pos, 0);
    button_pos = 0;
}

void move_key_cursor(byte x) {
    fill_current_pos(0);
    pos += x;
    redraw_key();
    fill_current_pos(1);
}

void redraw_key(void) {
    byte i;

    for (i = 0; i < KEY_LEN; i++) {
        gotoxy(4 + i, 8);
        if (key[i] != '\0') {
            cputc(key[i]);
        } else {
            cputc(c_removal);
        }
    }
}

void fill_current_pos(byte c) {
    if (pos < KEY_LEN) {
        if (key[pos] == '\0') {
            gotoxy(4 + pos, 8);
            if (c) {
                cputc('*');
            } else {
                cputc(c_removal);
            }
        } else {
            gotoxy(4 + pos, 8);
            if (c) {
                cputc('_');
            }
        }
    }
}

void main(void) {
    byte i;

    init_screen();

    while (1) {
        check_pad();
        if (btn_push(BTN_RIGHT)) {
            if (button_pos > 0) {
                if (button_pos < 4) {
                    play_se(0xae);
                    move_button_cursor(+1);
                }
            } else if (keyboard_pos[0] < 24) {
                move_keyboard_cursor(+2, 0);
            }
        } else if (btn_push(BTN_LEFT)) {
            if (button_pos > 0) {
                if (button_pos > 1) {
                    play_se(0xae);
                    move_button_cursor(-1);
                }
            } else if (keyboard_pos[0] > 0) {
                move_keyboard_cursor(-2, 0);
            }
        } else if (btn_push(BTN_DOWN)) {
            if (keyboard_pos[1] < 3) {
                move_keyboard_cursor(0, +1);
            } else if (button_pos == 0) {
                play_se(0xae);
                remove_keyboard_cursor();
                move_button_cursor(+1);
            }
        } else if (btn_push(BTN_UP)) {
            if (button_pos > 0) {
                remove_button_cursor();
                move_keyboard_cursor(0, 0);
            } else if (keyboard_pos[1] > 0) {
                move_keyboard_cursor(0, -1);
            }
        }

        if (btn_push(BTN_B)) {
            if (pos > 0) {
                play_se(0xff);
                move_key_cursor(-1);
            }
        }

        if (btn_push(BTN_A)) {
            if (button_pos > 0) {
                switch (button_pos) {
                case 1: // BACK
                    if (pos > 0) {
                        play_se(0xff);
                        move_key_cursor(-1);
                    }
                    break;
                case 2: // FORWARD
                    if (pos < KEY_LEN && key[pos] != '\0') {
                        play_se(0xff);
                        move_key_cursor(+1);
                    }
                    break;
                case 3: // DEL
                    delete_text();
                    break;
                case 4: // END
                    goto CHECK;
                    break;
                }
            } else if (pos < KEY_LEN) {
                key[pos] = char_table[keyboard_pos[1]][keyboard_pos[0] / 2];
                play_se(0xcf);
                move_key_cursor(+1);
            }
        }
    }

  CHECK:
    redraw_key();
    for (i = 0; i < 5; i++) {
        draw_message("checking key....", 0, 0);
        sleep(5000);
        draw_message("", 0, 0);
        sleep(5000);
    }
    if (check_key()) {
        draw_message("correct :)", 3, 1);
    } else {
        draw_message("wrong ;(", 4, 1);
    }

    while (1);
}
