﻿// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace System.Net.Http.Json
{
    /// <summary>
    /// Contains the extensions methods for using JSON as the content-type in HttpClient.
    /// </summary>
    public static partial class HttpClientJsonExtensions
    {
        public static Task<object?> GetFromJsonAsync(this HttpClient client, string? requestUri, Type type, JsonSerializerOptions? options = null, CancellationToken cancellationToken = default)
        {
            if (client == null)
            {
                throw new ArgumentNullException(nameof(client));
            }

            Task<HttpResponseMessage> taskResponse = client.GetAsync(requestUri, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
            return GetFromJsonAsyncCore(taskResponse, type, options, cancellationToken);
        }

        public static Task<object?> GetFromJsonAsync(this HttpClient client, Uri? requestUri, Type type, JsonSerializerOptions? options = null, CancellationToken cancellationToken = default)
        {
            if (client == null)
            {
                throw new ArgumentNullException(nameof(client));
            }

            Task<HttpResponseMessage> taskResponse = client.GetAsync(requestUri, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
            return GetFromJsonAsyncCore(taskResponse, type, options, cancellationToken);
        }

        public static Task<TValue> GetFromJsonAsync<TValue>(this HttpClient client, string? requestUri, JsonSerializerOptions? options = null, CancellationToken cancellationToken = default)
        {
            if (client == null)
            {
                throw new ArgumentNullException(nameof(client));
            }

            Task<HttpResponseMessage> taskResponse = client.GetAsync(requestUri, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
            return GetFromJsonAsyncCore<TValue>(taskResponse, options, cancellationToken);
        }

        public static Task<TValue> GetFromJsonAsync<TValue>(this HttpClient client, Uri? requestUri, JsonSerializerOptions? options = null, CancellationToken cancellationToken = default)
        {
            if (client == null)
            {
                throw new ArgumentNullException(nameof(client));
            }

            Task<HttpResponseMessage> taskResponse = client.GetAsync(requestUri, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
            return GetFromJsonAsyncCore<TValue>(taskResponse, options, cancellationToken);
        }

        public static Task<object?> GetFromJsonAsync(this HttpClient client, string? requestUri, Type type, CancellationToken cancellationToken = default)
            => client.GetFromJsonAsync(requestUri, type, null, cancellationToken);

        public static Task<object?> GetFromJsonAsync(this HttpClient client, Uri? requestUri, Type type, CancellationToken cancellationToken = default)
            => client.GetFromJsonAsync(requestUri, type, null, cancellationToken);

        public static Task<TValue> GetFromJsonAsync<TValue>(this HttpClient client, string? requestUri, CancellationToken cancellationToken = default)
            => client.GetFromJsonAsync<TValue>(requestUri, null, cancellationToken);

        public static Task<TValue> GetFromJsonAsync<TValue>(this HttpClient client, Uri? requestUri, CancellationToken cancellationToken = default)
            => client.GetFromJsonAsync<TValue>(requestUri, null, cancellationToken);

        private static async Task<object?> GetFromJsonAsyncCore(Task<HttpResponseMessage> taskResponse, Type type, JsonSerializerOptions? options, CancellationToken cancellationToken)
        {
            using (HttpResponseMessage response = await taskResponse.ConfigureAwait(false))
            {
                response.EnsureSuccessStatusCode();

                return await response.Content.ReadFromJsonAsync(type, options, cancellationToken).ConfigureAwait(false);
            }
        }

        private static async Task<T> GetFromJsonAsyncCore<T>(Task<HttpResponseMessage> taskResponse, JsonSerializerOptions? options, CancellationToken cancellationToken)
        {
            using (HttpResponseMessage response = await taskResponse.ConfigureAwait(false))
            {
                response.EnsureSuccessStatusCode();

                return await response.Content.ReadFromJsonAsync<T>(options, cancellationToken).ConfigureAwait(false);
            }
        }
    }
}
