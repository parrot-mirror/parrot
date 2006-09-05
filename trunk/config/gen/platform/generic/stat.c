/*
 * File stat stuff
 */

PMC *
Parrot_stat_file(Interp* interpreter, STRING *filename)
{
    return NULL;
}

PMC *
Parrot_stat_info_pmc(Interp* interpreter, STRING *filename, INTVAL thing)
{
    return NULL;
}

INTVAL
Parrot_stat_info_intval(Interp* interpreter, STRING *file, INTVAL thing)
{
    struct stat statbuf;
    char *filename;
    INTVAL result = -1;
    int status;

    /* Get the name of the file as something we can use */
    filename = string_to_cstring(interpreter, file);

    /* Everything needs the result of stat, so just go do it */
    status = stat(filename, &statbuf);
    if (thing == STAT_EXISTS)
	return status == 0;
    if (status == -1) {
	const char *err = strerror(errno);
	real_exception(interpreter, NULL, E_IOError,
		"stat failed: %s", err);
    }

    switch (thing) {
	case STAT_FILESIZE:
	    result = statbuf.st_size;
	    break;
	case STAT_ISDIR:
	    result = S_ISDIR(statbuf.st_mode);
	    break;
	case STAT_ISDEV:
	    result = S_ISCHR(statbuf.st_mode) || S_ISBLK(statbuf.st_mode);
	    break;
	case STAT_CREATETIME:
	    result = -1;
	    break;
	case STAT_ACCESSTIME:
	    result = statbuf.st_atime;
	    break;
	case STAT_MODIFYTIME:
	    result = statbuf.st_mtime;
	    break;
	case STAT_CHANGETIME:
	    result = statbuf.st_ctime;
	    break;
	case STAT_BACKUPTIME:
	    result = -1;
	    break;
	case STAT_UID:
	    result = statbuf.st_uid;
	    break;
	case STAT_GID:
	    result = statbuf.st_gid;
	    break;
	case STAT_PLATFORM_DEV:
	    result = statbuf.st_dev;
	    break;
	case STAT_PLATFORM_INODE:
	    result = statbuf.st_ino;
	    break;
	case STAT_PLATFORM_MODE:
	    result = statbuf.st_mode;
	    break;
	case STAT_PLATFORM_NLINKS:
	    result = statbuf.st_nlink;
	    break;
	case STAT_PLATFORM_DEVTYPE:
	    result = statbuf.st_rdev;
	    break;
	case STAT_PLATFORM_BLOCKSIZE:
	    result = statbuf.st_blksize;
	    break;
	case STAT_PLATFORM_BLOCKS:
	    result = statbuf.st_blocks;
	    break;
    }

    string_cstring_free(filename);
    return result;
}

INTVAL
Parrot_fstat_info_intval(Interp* interpreter, INTVAL file, INTVAL thing)
{
    struct stat statbuf;
    INTVAL result = -1;
    int status;

    /* Everything needs the result of stat, so just go do it */
    status = fstat(file, &statbuf);
    if (thing == STAT_EXISTS)
	return status == 0;
    if (status == -1) {
	const char *err = strerror(errno);
	real_exception(interpreter, NULL, E_IOError,
		"stat failed: %s", err);
    }

    switch (thing) {
	case STAT_FILESIZE:
	    result = statbuf.st_size;
	    break;
	case STAT_ISDIR:
	    result = S_ISDIR(statbuf.st_mode);
	    break;
	case STAT_ISDEV:
	    result = S_ISCHR(statbuf.st_mode) || S_ISBLK(statbuf.st_mode);
	    break;
	case STAT_CREATETIME:
	    result = -1;
	    break;
	case STAT_ACCESSTIME:
	    result = statbuf.st_atime;
	    break;
	case STAT_MODIFYTIME:
	    result = statbuf.st_mtime;
	    break;
	case STAT_CHANGETIME:
	    result = statbuf.st_ctime;
	    break;
	case STAT_BACKUPTIME:
	    result = -1;
	    break;
	case STAT_UID:
	    result = statbuf.st_uid;
	    break;
	case STAT_GID:
	    result = statbuf.st_gid;
	    break;
	case STAT_PLATFORM_DEV:
	    result = statbuf.st_dev;
	    break;
	case STAT_PLATFORM_INODE:
	    result = statbuf.st_ino;
	    break;
	case STAT_PLATFORM_MODE:
	    result = statbuf.st_mode;
	    break;
	case STAT_PLATFORM_NLINKS:
	    result = statbuf.st_nlink;
	    break;
	case STAT_PLATFORM_DEVTYPE:
	    result = statbuf.st_rdev;
	    break;
	case STAT_PLATFORM_BLOCKSIZE:
	    result = statbuf.st_blksize;
	    break;
	case STAT_PLATFORM_BLOCKS:
	    result = statbuf.st_blocks;
	    break;
    }

    return result;
}

FLOATVAL
Parrot_stat_info_floatval(Interp* interpreter, STRING *filename, INTVAL thing)
{
    return -1;
}

STRING *
Parrot_stat_info_string(Interp* interpreter, STRING *filename, INTVAL thing)
{
    return NULL;
}
