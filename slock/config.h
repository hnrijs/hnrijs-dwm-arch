static const char *user  = "nobody";
static const char *group = "nobody";

static const char *colorname[NUMCOLS] = {
    [INIT] =   "#1e1e2e",   /* after initialization (Mocha Base) */
    [INPUT] =  "#89b4fa",   /* during input (Mocha Blue) */
    [FAILED] = "#f38ba8",   /* wrong password (Mocha Red) */
};
/* treat a cleared input like a wrong password */
static const int failonclear = 1;
