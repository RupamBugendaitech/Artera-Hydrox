public class UserDetailsObjectApex {
    
        public class metadata_Z {
            public String type_Z {get;set;} // in json: type

            public metadata_Z(JSONParser parser) {
                while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                    if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                        String text = parser.getText();
                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                            if (text == 'type') {
                                type_Z = parser.getText();
                            } else {
                                System.debug(LoggingLevel.WARN, 'metadata_Z consuming unrecognized property: '+text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }
        
    public d d {
        get;
        set;
    }

    public UserDetailsObjectApex(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'd') {
                        d = new d(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'UserDetailsObjectApex consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public class d {
        public List < Results > results {
            get;
            set;
        }

        public d(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'results') {
                            results = arrayOfResults(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'd consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Results {
        public metadata xmetadata {
            get;
            set;
        } // in json: _metadata
        public Alerts Alerts {
            get;
            set;
        }
        public Alerts Groups {
            get;
            set;
        }
        public Integer Id {
            get;
            set;
        }
        public Boolean IsHiddenInUI {
            get;
            set;
        }
        public String LoginName {
            get;
            set;
        }
        public String Title {
            get;
            set;
        }
        public Integer PrincipalType {
            get;
            set;
        }
        public String Email {
            get;
            set;
        }
        public String Expiration {
            get;
            set;
        }
        public Boolean IsEmailAuthenticationGuestUser {
            get;
            set;
        }
        public Boolean IsShareByEmailGuestUser {
            get;
            set;
        }
        public Boolean IsSiteAdmin {
            get;
            set;
        }
        public UserId UserId {
            get;
            set;
        }
        public String UserPrincipalName {
            get;
            set;
        }

        public Results(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '_metadata') {
                            xmetadata = new metadata(parser);
                        } else if (text == 'Alerts') {
                            Alerts = new Alerts(parser);
                        } else if (text == 'Groups') {
                            Groups = new Alerts(parser);
                        } else if (text == 'Id') {
                            Id = parser.getIntegerValue();
                        } else if (text == 'IsHiddenInUI') {
                            IsHiddenInUI = parser.getBooleanValue();
                        }
                        /* else if (text == 'LoginName') {
                                                    LoginName = parser.getText();
                                                }*/
                        else if (text == 'Title') {
                            Title = parser.getText();
                        } else if (text == 'PrincipalType') {
                            PrincipalType = parser.getIntegerValue();
                        } else if (text == 'Email') {
                            Email = parser.getText();
                        } else if (text == 'Expiration') {
                            Expiration = parser.getText();
                        } else if (text == 'IsEmailAuthenticationGuestUser') {
                            IsEmailAuthenticationGuestUser = parser.getBooleanValue();
                        } else if (text == 'IsShareByEmailGuestUser') {
                            IsShareByEmailGuestUser = parser.getBooleanValue();
                        } else if (text == 'IsSiteAdmin') {
                            IsSiteAdmin = parser.getBooleanValue();
                        } else if (text == 'UserId') {
                            UserId = new UserId(parser);
                        } else if (text == 'UserPrincipalName') {
                            UserPrincipalName = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Results consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class UserId {
        //   public metadata_Z xmetadata {get;set;} // in json: _metadata
        public String NameId {
            get;
            set;
        }
        public String NameIdIssuer {
            get;
            set;
        }

        public UserId(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '_metadata') {
                            // xmetadata = new metadata_Z(parser);
                        } else if (text == 'NameId') {
                            NameId = parser.getText();
                        } else if (text == 'NameIdIssuer') {
                            NameIdIssuer = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'UserId consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Alerts {
        public deferred xdeferred {
            get;
            set;
        } // in json: _deferred

        public Alerts(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '_deferred') {
                            xdeferred = new deferred(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Alerts consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class metadata {
        public String id {
            get;
            set;
        }
        public String uri {
            get;
            set;
        }
        public String type_Z {
            get;
            set;
        } // in json: type

        public metadata(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'uri') {
                            uri = parser.getText();
                        } else if (text == 'type') {
                            type_Z = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'metadata consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class deferred {
        public String uri {
            get;
            set;
        }

        public deferred(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'uri') {
                            uri = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'deferred consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public static UserDetailsObjectApex parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new UserDetailsObjectApex(parser);
    }

    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT ||
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }



    private static List < Results > arrayOfResults(System.JSONParser p) {
        List < Results > res = new List < Results > ();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Results(p));
        }
        return res;
    }
}