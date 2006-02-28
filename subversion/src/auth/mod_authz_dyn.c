#define APR_WANT_STRFUNC
#include "apr_want.h"
#include "apr_strings.h"
#include "apr_dbm.h"
#include "apr_md5.h"

#include "httpd.h"
#include "http_config.h"
#include "http_core.h"
#include "http_log.h"
#include "http_protocol.h"
#include "http_request.h"


typedef struct {
    char * prefix;
    char * dbmreaders;
    char * dbmwriters;
    char * dbmtype;
} authz_dyn_config_rec;


static const command_rec authz_dyn_cmds[] =
{
    AP_INIT_TAKE1("AuthzRepoPrefix", ap_set_string_slot,
     (void *) APR_OFFSETOF(authz_dyn_config_rec, prefix),
     OR_AUTHCFG, "prefix to be stripped to get repository name"),
    AP_INIT_TAKE1("AuthzRepoReaders", ap_set_file_slot,
     (void *) APR_OFFSETOF(authz_dyn_config_rec, dbmreaders),
     OR_AUTHCFG, "database file containing allowed repository readers"),
    AP_INIT_TAKE1("AuthzRepoWriters", ap_set_file_slot,
     (void *) APR_OFFSETOF(authz_dyn_config_rec, dbmwriters),
     OR_AUTHCFG, "database file containing allowed repository writers"),
    AP_INIT_TAKE1("AuthzRepoDBType", ap_set_string_slot,
     (void *) APR_OFFSETOF(authz_dyn_config_rec, dbmtype),
     OR_AUTHCFG, "type of reposity access databases"),
    {NULL}
};


module AP_MODULE_DECLARE_DATA authz_dyn_module;


static void *create_authz_dyn_dir_config(apr_pool_t * p, char * d)
{
    authz_dyn_config_rec * conf = apr_palloc(p, sizeof(*conf));

    conf->prefix = 0;
    conf->dbmreaders = 0;
    conf->dbmwriters = 0;
    conf->dbmtype = "unknown";

    return conf;
}


/* Copied verbatim from mod_authz_dbm.c. */
static apr_status_t get_dbm_entry_as_str(request_rec *r, char *user,
                                         char *auth_dbmfile, char *dbtype,
                                         char ** str)
{
    apr_dbm_t *f;
    apr_datum_t d, q;
    apr_status_t retval;
    q.dptr = user;

#ifndef NETSCAPE_DBM_COMPAT
    q.dsize = strlen(q.dptr);
#else
    q.dsize = strlen(q.dptr) + 1;
#endif

    retval = apr_dbm_open_ex(&f, dbtype, auth_dbmfile, APR_DBM_READONLY, 
                             APR_OS_DEFAULT, r->pool);

    if (retval != APR_SUCCESS) {
        return retval;
    }

    *str = NULL;

    if (apr_dbm_fetch(f, q, &d) == APR_SUCCESS && d.dptr) {
        *str = apr_palloc(r->pool, d.dsize + 1);
        strncpy(*str, d.dptr, d.dsize);
        (*str)[d.dsize] = '\0'; /* Terminate the string */
    }

    apr_dbm_close(f);

    return retval;
}


static int dyn_check_auth(request_rec * r)
{
    authz_dyn_config_rec *conf = ap_get_module_config(
        r->per_dir_config, &authz_dyn_module);
    char * user = r->user;
    int m = r->method_number;
    const apr_array_header_t  *reqs_arr = ap_requires(r);
    require_line * reqs = reqs_arr ? (require_line *) reqs_arr->elts : NULL;
    int x;
    const char * t;
    char * w;
    apr_status_t status;
    char * repo;
    char * users, * u;
    char * dbm;
        
    ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "check_auth");

    if (!conf->prefix) return DECLINED;
    if (!reqs_arr) return DECLINED;

    for (x = 0; x < reqs_arr->nelts; x++) {

        if (!(reqs[x].method_mask & (AP_METHOD_BIT << m))) continue;

        t = reqs[x].requirement;
        w = ap_getword_white(r->pool, &t);
 
        if (strcmp(w, "repo-reader") == 0 || 
            strcmp(w, "repo-writer") == 0)
        {
            ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r,
                "checking repo access");

            ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r,
                "uri = %s", r->uri);

            if (strncmp(r->uri, conf->prefix, strlen(conf->prefix)) != 0
                || !r->uri[strlen(conf->prefix)])
            {
                ap_log_rerror(APLOG_MARK, APLOG_ERR, 0, r,
                    "wrong prefix, expected %s", conf->prefix);
                return HTTP_NOT_FOUND;
            }

            t = r->uri + strlen(conf->prefix);
            repo = ap_getword(r->pool, &t, '/');
            
            dbm = strcmp(w, "repo-reader") == 0 ?
                conf->dbmreaders : conf->dbmwriters;
            if (!dbm) {
                ap_log_rerror(APLOG_MARK, APLOG_ERR, 0, r,
                    "no database specified");
                return HTTP_INTERNAL_SERVER_ERROR;
            }
            
            ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r,
                "%s / %s / %s / %s", dbm, conf->dbmtype, user, repo);
            status = get_dbm_entry_as_str(r, repo,
                dbm, conf->dbmtype, &users);
            if (status != APR_SUCCESS) {
                ap_log_rerror(APLOG_MARK, APLOG_ERR, errno, r,
                    "cannot query database");
                return status;
            }
            if (!users) {
                ap_log_rerror(APLOG_MARK, APLOG_ERR, errno, r,
                    "no ACL for %s", repo);
                return HTTP_NOT_FOUND;
            }

            ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, 
                "allowed users: %s", users);

            if (user && strcmp(user, "root") == 0) {
              ap_log_rerror(APLOG_MARK, APLOG_INFO, 0, r, 
                 "ROOT access to repo %s", repo);
              return OK;
            }

            /* Access is permitted if:
               - "all" is in the ACL and the access type is read
                 access (so universal write access is not possible);
                 or 
               - the name of the user is known (i.e., hasn't been set
                 to NULL by mod_authn_noauth) and is in the ACL.
            */
            while (*users && (u = ap_getword(r->pool, &users, ','))) {
                if ((strcmp(u, "all") == 0 && strcmp(w, "repo-reader") == 0)
                    || (user && strcmp(u, user) == 0))
                {
                    ap_log_rerror(APLOG_MARK, APLOG_INFO, 0, r, 
                        "user %s allowed to repo %s", user, repo);
                    return OK;
                }
            }

            ap_log_rerror(APLOG_MARK, APLOG_ERR, 0, r, 
                "user %s denied to repo %s", user, repo);

            ap_note_basic_auth_failure(r);
            return HTTP_UNAUTHORIZED;
        }
    }

    return DECLINED;
}


static void register_hooks(apr_pool_t * p)
{
    ap_hook_auth_checker(dyn_check_auth, NULL, NULL, APR_HOOK_MIDDLE);
}


module AP_MODULE_DECLARE_DATA authz_dyn_module =
{
    STANDARD20_MODULE_STUFF,
    create_authz_dyn_dir_config,    /* dir config creater */
    NULL,                           /* dir merger --- default is to override */
    NULL,                           /* server config */
    NULL,                           /* merge server config */
    authz_dyn_cmds,                 /* command apr_table_t */
    register_hooks                  /* register hooks */
};
