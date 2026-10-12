allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Some older plugins (e.g. connectivity_plus 5.x, pulled in by flutter_offline)
// hard-code compileSdk 33, but their AndroidX dependencies need 34+.
// Raise every Android library plugin to at least SDK 37 (never lower one).
subprojects {
    if (project.name != "app") {
        project.afterEvaluate {
            project.extensions
                .findByType(com.android.build.api.dsl.LibraryExtension::class.java)
                ?.apply { if ((compileSdk ?: 0) < 37) compileSdk = 37 }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
