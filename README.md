
1. Dependencies:
    ```
    $ elm install elm/json
    $ elm install elm/http
    $  elm install elm/time
    $ elm install NoRedInk/elm-json-decode-pipeline
    $ elm install krisajenkins/remotedata
    $ elm install TSFoster/elm-uuid
    $ elm install elm/url
   ```

2. Test:
    ```
    $ npm install elm-test -g
    $ elm-test init
    $ elm-test
    ```
   
3. Dev Server with elm-live:
    ```
    $ npm install elm-live -g
    $ elm-live src/Main.elm --pushstate
    ```
   
    
4. Dev Server with http-server:
    ```
    $ npm install http-server -g
    $ http-server -p 8000 -c -1
    ```
 
5. Make JS:
    ```
    $ elm make src/Main.elm --output main.js --optimize
    ```
 
6. Uglify: 
    ```
    $ npm install --global uglify-js
    $ uglifyjs main.js --compress -o main.js 
    $ uglifyjs main.js --mangle -o main.js
    ```