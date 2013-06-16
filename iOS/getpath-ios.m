/* Return the initial module search path. */

#include "Python.h"
#include "osdefs.h"

#include <sys/types.h>
#include <string.h>

#import <Foundation/Foundation.h>

/* The original getpath.c looks for python libraries in various places.
 *
 * On iOS, we do not - we already know exactly where any python code will
 * be deployed.  furthermore, there is no EXEC_PREFIX since we can't
 * do dynamic loading.
 *
 * We set both of these to PythonPath, unless PythonHome is set.  If 
 * PythonHome is set, we use it instead.
 */

#ifdef __cplusplus
 extern "C" {
#endif

#ifndef VPATH
#define VPATH "."
#endif

#ifndef PYTHONPATH
#define PYTHONPATH ios_PythonPath()
#endif

static char python_path[MAXPATHLEN+1] = "";
static char prefix[MAXPATHLEN+1];
static char exec_prefix[MAXPATHLEN+1];
static char progpath[MAXPATHLEN+1];
static char *module_search_path = NULL;
     
/* The PYTHONPATH on iOS should always point into the application bundle
 *
 * This can be worked out at run-time (and should be).
*/
static char *
ios_PythonPath()
{
    /* check to see if we've already computed python_path */
    if (python_path[0] != '\0') {
        return python_path;
    }
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *pythonPath = [[bundle resourcePath] stringByAppendingPathComponent:@"Python"];
    if ([pythonPath getFileSystemRepresentation:python_path maxLength:MAXPATHLEN]) {
        return python_path;
    } else {
        return NULL;
    }
}
     

static void
reduce(char *dir)
{
    size_t i = strlen(dir);
    while (i > 0 && dir[i] != SEP)
        --i;
    dir[i] = '\0';
}


static int
isfile(char *filename)          /* Is file, not directory */
{
    struct stat buf;
    if (stat(filename, &buf) != 0)
        return 0;
    if (!S_ISREG(buf.st_mode))
        return 0;
    return 1;
}


static int
ismodule(char *filename)        /* Is module -- check for .pyc/.pyo too */
{
    if (isfile(filename))
        return 1;

    /* Check for the compiled version of prefix. */
    if (strlen(filename) < MAXPATHLEN) {
        strcat(filename, Py_OptimizeFlag ? "o" : "c");
        if (isfile(filename))
            return 1;
    }
    return 0;
}


static int
isxfile(char *filename)         /* Is executable file */
{
    struct stat buf;
    if (stat(filename, &buf) != 0)
        return 0;
    if (!S_ISREG(buf.st_mode))
        return 0;
    if ((buf.st_mode & 0111) == 0)
        return 0;
    return 1;
}


static int
isdir(char *filename)                   /* Is directory */
{
    struct stat buf;
    if (stat(filename, &buf) != 0)
        return 0;
    if (!S_ISDIR(buf.st_mode))
        return 0;
    return 1;
}


/* Add a path component, by appending stuff to buffer.
   buffer must have at least MAXPATHLEN + 1 bytes allocated, and contain a
   NUL-terminated string with no more than MAXPATHLEN characters (not counting
   the trailing NUL).  It's a fatal error if it contains a string longer than
   that (callers must be careful!).  If these requirements are met, it's
   guaranteed that buffer will still be a NUL-terminated string with no more
   than MAXPATHLEN characters at exit.  If stuff is too long, only as much of
   stuff as fits will be appended.
*/
static void
joinpath(char *buffer, char *stuff)
{
    size_t n, k;
    if (stuff[0] == SEP)
        n = 0;
    else {
        n = strlen(buffer);
        if (n > 0 && buffer[n-1] != SEP && n < MAXPATHLEN)
            buffer[n++] = SEP;
    }
    if (n > MAXPATHLEN)
        Py_FatalError("buffer overflow in getpath.c's joinpath()");
    k = strlen(stuff);
    if (n + k > MAXPATHLEN)
        k = MAXPATHLEN - n;
    strncpy(buffer+n, stuff, k);
    buffer[n+k] = '\0';
}

/* copy_absolute requires that path be allocated at least
   MAXPATHLEN + 1 bytes and that p be no more than MAXPATHLEN bytes. */
static void
copy_absolute(char *path, char *p)
{
    if (p[0] == SEP)
        strcpy(path, p);
    else {
        if (!getcwd(path, MAXPATHLEN)) {
            /* unable to get the current directory */
            strcpy(path, p);
            return;
        }
        if (p[0] == '.' && p[1] == SEP)
            p += 2;
        joinpath(path, p);
    }
}

/* absolutize() requires that path be allocated at least MAXPATHLEN+1 bytes. */
static void
absolutize(char *path)
{
    char buffer[MAXPATHLEN + 1];

    if (path[0] == SEP)
        return;
    copy_absolute(buffer, path);
    strcpy(path, buffer);
}

static void
calculate_path(void)
{
    char *pythonpath = PYTHONPATH;
    char *home = Py_GetPythonHome();
    
    if (home != NULL) {
        strncpy(prefix, home, MAXPATHLEN+1);
    } else {
        strncpy(prefix, pythonpath, MAXPATHLEN+1);
    }
    strncpy(exec_prefix, prefix, MAXPATHLEN+1);
    module_search_path = prefix;
    NSLog(@"Home Path: %@", NSHomeDirectory());
    NSLog(@"Setting Search path to %s\n", module_search_path);
}


/* External interface */

char *
Py_GetPath(void)
{
    if (!module_search_path)
        calculate_path();
    return module_search_path;
}

char *
Py_GetPrefix(void)
{
    if (!module_search_path)
        calculate_path();
    return prefix;
}

char *
Py_GetExecPrefix(void)
{
    if (!module_search_path)
        calculate_path();
    return exec_prefix;
}

char *
Py_GetProgramFullPath(void)
{
    if (!module_search_path)
        calculate_path();
    return progpath;
}


#ifdef __cplusplus
}
#endif

