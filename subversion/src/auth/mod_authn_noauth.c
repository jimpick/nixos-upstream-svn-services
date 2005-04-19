#define APR_WANT_STRFUNC
#include "apr_want.h"
#include "apr_strings.h"
#include "apr_md5.h"

#include "ap_provider.h"
#include "httpd.h"
#include "http_config.h"
#include "http_core.h"
#include "http_log.h"
#include "http_protocol.h"
#include "http_request.h"


typedef struct {
    int allow_no_auth; /* allow requests with no authentication */
} authn_noauth_config_rec;


static void *create_authn_noauth_dir_config(apr_pool_t *p, char *d)
{
    authn_noauth_config_rec *conf = apr_palloc(p, sizeof(*conf));
    conf->allow_no_auth = 0;
    return conf;
}


static const command_rec authn_noauth_cmds[] =
{
    AP_INIT_FLAG("AuthAllowNone", ap_set_flag_slot,
                 (void *)APR_OFFSETOF(authn_noauth_config_rec, allow_no_auth),
                 OR_AUTHCFG,
                 "Whether to allow access without any authentication."),
    {NULL}
};


module AP_MODULE_DECLARE_DATA authn_noauth_module;


static int authenticate_noauth(request_rec * r)
{
    authn_noauth_config_rec * conf = ap_get_module_config(
        r->per_dir_config, &authn_noauth_module);
    const char * auth_line;

    ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r, "noauth");

    /* If no authentication info, accept. */

    auth_line = apr_table_get(r->headers_in, 
        (PROXYREQ_PROXY == r->proxyreq)
        ? "Proxy-Authorization"
        : "Authorization");

    if (conf->allow_no_auth && !auth_line)
        return OK;
    else
        return DECLINED;
}


static void register_hooks(apr_pool_t *p)
{
    ap_hook_check_user_id(authenticate_noauth, NULL, NULL, APR_HOOK_MIDDLE);
}


module AP_MODULE_DECLARE_DATA authn_noauth_module =
{
    STANDARD20_MODULE_STUFF,
    create_authn_noauth_dir_config, /* dir config creater */
    NULL,                           /* dir merger --- default is to override */
    NULL,                           /* server config */
    NULL,                           /* merge server config */
    authn_noauth_cmds,              /* command apr_table_t */
    register_hooks                  /* register hooks */
};
