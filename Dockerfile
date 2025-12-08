FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

ARG FOLDER=/app

COPY . /app

WORKDIR ${FOLDER}

RUN dotnet tool restore \
    && dotnet tool run libman restore \
    && dotnet publish component-blazor.csproj -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime

ARG FOLDER=/app

WORKDIR ${FOLDER}

COPY --from=build ${FOLDER}/out ./

EXPOSE 5054

ENV ASPNETCORE_URLS=http://+:5054

CMD ["dotnet", "component-blazor.dll"]
