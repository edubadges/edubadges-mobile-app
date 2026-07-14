import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "nl.surf.edubadges"
            resValue(type = "string", name = "app_name", value = "Edubadges Dev")
            manifestPlaceholders["appAuthRedirectScheme"] = "edubadges"
        }
        create("tst") {
            dimension = "flavor-type"
            applicationId = "nl.surf.edubadges"
            resValue(type = "string", name = "app_name", value = "Edubadges Tst")
            manifestPlaceholders["appAuthRedirectScheme"] = "edubadges"
        }
        create("acc") {
            dimension = "flavor-type"
            applicationId = "nl.surf.edubadges"
            resValue(type = "string", name = "app_name", value = "Edubadges Acc")
            manifestPlaceholders["appAuthRedirectScheme"] = "edubadges"
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "nl.surf.edubadges"
            resValue(type = "string", name = "app_name", value = "Edubadges")
            // Reverse of clientId `edubadges.mobile`; SurfConext SP Dashboard
            // only accepts this reverse-DNS scheme for the prod client.
            manifestPlaceholders["appAuthRedirectScheme"] = "mobile.edubadges"
        }
    }
}