plugins {
    // ... other existing plugins

    // Add the dependency for the Google services Gradle plugin
    id("com.google.gms.google-services") version "4.4.3" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // REMOVE THIS dependencies block:
    // dependencies {
    //     classpath("com.google.gms:google-services:4.4.0") // This line causes the error
    // }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.set(newBuildDir) // Use .set() for Provider

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir) // Use .set() for Provider
}
// It's unusual to have evaluationDependsOn for all subprojects on :app
// Consider if this is truly necessary, as it can create circular dependencies
// or slow down configuration.
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
