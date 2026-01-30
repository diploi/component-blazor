<img alt="icon" src=".diploi/icon.svg" width="32">

# Blazor Component for Diploi

[![launch with diploi badge](https://diploi.com/launch.svg)](https://diploi.com/component/blazor)
[![component on diploi badge](https://diploi.com/component.svg)](https://diploi.com/component/blazor)
[![latest tag badge](https://badgen.net/github/tag/diploi/component-blazor)](https://diploi.com/component/blazor)

## Operation

### Getting started

1. In the Dashboard, click **Create Project +**
2. Under **Pick Components**, choose **Blazor**. Here you can also add a backend framework to create a monorepo app
3. In **Pick Add-ons**, you can add one or multiple databases to your app
4. Choose **Create Repository** to generate a new GitHub repo
5. Finally, click **Launch Stack**

Link to the full guide - upcoming

### Development

During development, the container uses the combination of `nodemon` and `dotnet watch` to enable automatic reloads when files and new dependencies change. The development server is started with:

```sh
dotnet watch run \
    --no-launch-profile \
    --non-interactive
```

This will:
- Use `dotnet watch` to monitor for changes to .cs, .razor, and .css files and restart the server when changes are detected.
- Run the Blazor Server application with hot reload enabled.
- Start the app on port 5054.
- Avoid using any launch profile so environment variables are controlled by the container.

### Installing Packages

**Front-end libraries** (CSS/JS frameworks like Bootstrap, jQuery, etc.):

First, ensure .NET tools are restored:
```sh
dotnet tool restore
```

Then install front-end libraries using LibMan:
```sh
dotnet tool run libman install <library>@<version> --provider cdnjs --destination wwwroot/lib/<library>
```

For example:
```sh
dotnet tool run libman install bootstrap@5.3.0 --provider cdnjs --destination wwwroot/lib/bootstrap
dotnet tool run libman install jquery@3.7.1 --provider cdnjs --destination wwwroot/lib/jquery
```

**NuGet packages** (C# libraries and frameworks):
```sh
dotnet add package <PackageName>
```
For example:
```sh
dotnet add package Newtonsoft.Json
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
```

The `libman.json` file manages client-side libraries, while the `.csproj` file tracks NuGet dependencies. Both are automatically restored during development and build.

`dotnet add package` updates the `.csproj` and restores the package to the local NuGet cache. `nodemon` notices the new package reference in `component-blazor.csproj` and restarts the runtime so the change is picked up immediately.

### Production
 
Builds a production-ready image. During the build, dependencies are restored with `dotnet restore` and the application is published with `dotnet publish`. When the container starts, it runs:

```sh
dotnet component-blazor.dll
```

This uses the compiled .NET application optimized for production deployment.

### Data Protection

The application uses ASP.NET Core Data Protection for securing authentication cookies and anti-forgery tokens. In Kubernetes deployments, data protection keys are persisted using a PersistentVolumeClaim to ensure session continuity across pod restarts.

## Links

- [Blazor documentation](https://docs.microsoft.com/en-us/aspnet/core/blazor/)
- [ASP.NET Core documentation](https://docs.microsoft.com/en-us/aspnet/core/)
- [.NET documentation](https://docs.microsoft.com/en-us/dotnet/)