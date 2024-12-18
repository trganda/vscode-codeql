/**
 * @name all sink query
 * @description a basic query for java sink
 * @kind path-problem
 * @problem.severity warning
 * @id java/basic
 */

import java
import semmle.code.java.security.AndroidIntentRedirection
import semmle.code.java.security.AndroidIntentRedirectionQuery
import semmle.code.java.security.AndroidSensitiveCommunicationQuery
import semmle.code.java.security.CleartextStorageAndroidDatabaseQuery
import semmle.code.java.security.CleartextStorageAndroidFilesystemQuery
import semmle.code.java.security.CleartextStorageClassQuery
import semmle.code.java.security.CleartextStorageCookieQuery
import semmle.code.java.security.CleartextStoragePropertiesQuery
import semmle.code.java.security.CleartextStorageQuery
import semmle.code.java.security.CleartextStorageSharedPrefsQuery
import semmle.code.java.security.CommandArguments
import semmle.code.java.security.CommandLineQuery
import semmle.code.java.security.ConditionalBypassQuery
import semmle.code.java.security.ControlledString
import semmle.code.java.security.Encryption
import semmle.code.java.security.ExternalAPIs
import semmle.code.java.security.ExternalProcess
import semmle.code.java.security.FileReadWrite
import semmle.code.java.security.FileWritable
import semmle.code.java.security.FragmentInjection
import semmle.code.java.security.FragmentInjectionQuery
import semmle.code.java.security.GroovyInjection
import semmle.code.java.security.GroovyInjectionQuery
import semmle.code.java.security.HttpsUrls
import semmle.code.java.security.HttpsUrlsQuery
import semmle.code.java.security.ImplicitPendingIntents
import semmle.code.java.security.ImplicitPendingIntentsQuery
import semmle.code.java.security.InformationLeak
import semmle.code.java.security.InsecureBasicAuth
import semmle.code.java.security.InsecureBasicAuthQuery
import semmle.code.java.security.InsecureTrustManager
import semmle.code.java.security.InsecureTrustManagerQuery
import semmle.code.java.security.IntentUriPermissionManipulation
import semmle.code.java.security.IntentUriPermissionManipulationQuery
import semmle.code.java.security.JWT
import semmle.code.java.security.JexlInjectionQuery
import semmle.code.java.security.JndiInjection
import semmle.code.java.security.JndiInjectionQuery
import semmle.code.java.security.LdapInjection
import semmle.code.java.security.LogInjection
import semmle.code.java.security.LogInjectionQuery
import semmle.code.java.security.Mail
import semmle.code.java.security.MissingJWTSignatureCheckQuery
import semmle.code.java.security.MvelInjection
import semmle.code.java.security.MvelInjectionQuery
import semmle.code.java.security.OgnlInjection
import semmle.code.java.security.OgnlInjectionQuery
import semmle.code.java.security.PathCreation
import semmle.code.java.security.QueryInjection
import semmle.code.java.security.RandomDataSource
import semmle.code.java.security.RandomQuery
import semmle.code.java.security.RelativePaths
import semmle.code.java.security.RequestForgery
import semmle.code.java.security.RequestForgeryConfig
import semmle.code.java.security.ResponseSplitting
import semmle.code.java.security.SecurityFlag
import semmle.code.java.security.SecurityTests
import semmle.code.java.security.SensitiveActions
import semmle.code.java.security.SensitiveLoggingQuery
import semmle.code.java.security.SpelInjection
import semmle.code.java.security.SpelInjectionQuery
import semmle.code.java.security.UnsafeAndroidAccess
import semmle.code.java.security.UnsafeAndroidAccessQuery
import semmle.code.java.security.UnsafeCertTrust
import semmle.code.java.security.UnsafeCertTrustQuery
import semmle.code.java.security.UnsafeDeserializationQuery
import semmle.code.java.security.UrlRedirect
import semmle.code.java.security.Validation
import semmle.code.java.security.XPath
import semmle.code.java.security.XSS
import semmle.code.java.security.XmlParsers
import semmle.code.java.security.XsltInjection
import semmle.code.java.security.XsltInjectionQuery

import semmle.code.java.dataflow.DataFlow
import semmle.code.java.StringFormat

from Constructor url, MethodAccess call, Expr formatString
where
  url.getDeclaringType().hasQualifiedName("java.net", "URL") and
  url = call.getCallee() and
  formatString instanceof StringLiteral and
  DataFlow::localFlow(DataFlow::exprNode(formatString), DataFlow::exprNode(call.getArgument(0)))
select call, "hard code to create java.net.URL"
