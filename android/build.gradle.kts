allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // superwallkit_flutter's own Android module is compiled against API 34
    // and doesn't request androidx.activity itself, but Gradle's
    // highest-version-wins resolution otherwise pulls in
    // androidx.activity(-ktx) 1.10.1 (requested elsewhere in the
    // dependency graph), which requires compiling against API 35+ and
    // fails superwallkit_flutter's own AAR metadata check. Pinning to the
    // last 1.9.x release keeps every module on a version compatible with
    // API 34 until superwallkit_flutter ships an update.
    configurations.all {
        resolutionStrategy {
            force("androidx.activity:activity:1.9.3")
            force("androidx.activity:activity-ktx:1.9.3")
        }
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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
