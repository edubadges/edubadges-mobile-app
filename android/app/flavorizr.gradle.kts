import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

// `appAuthRedirectScheme` must match the scheme of the redirect URI in
// oidc_auth_datasource.dart, which SurfConext registers for every client.
android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "nl.surf.edubadges"
            resValue(type = "string", name = "app_name", value = "Edubadges Dev")
            manifestPlaceholders["appAuthRedirectScheme"] = "mobile.edubadges"
        }
        create("tst") {
            dimension = "flavor-type"
            applicationId = "nl.surf.edubadges"
            resValue(type = "string", name = "app_name", value = "Edubadges Tst")
            manifestPlaceholders["appAuthRedirectScheme"] = "mobile.edubadges"
        }
        create("acc") {
            dimension = "flavor-type"
            applicationId = "nl.surf.edubadges"
            resValue(type = "string", name = "app_name", value = "Edubadges Acc")
            manifestPlaceholders["appAuthRedirectScheme"] = "mobile.edubadges"
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "nl.surf.edubadges"
            resValue(type = "string", name = "app_name", value = "Edubadges")
            manifestPlaceholders["appAuthRedirectScheme"] = "mobile.edubadges"
        }
    }
}