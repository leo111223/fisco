"""
    The Plaid API

    The Plaid REST API. Please see https://plaid.com/docs/api for more details.  # noqa: E501

    The version of the OpenAPI document: 2020-09-14_1.620.0
    Generated by: https://openapi-generator.tech
"""


import re  # noqa: F401
import sys  # noqa: F401

from plaid.model_utils import (  # noqa: F401
    ApiTypeError,
    ModelComposed,
    ModelNormal,
    ModelSimple,
    cached_property,
    change_keys_js_to_python,
    convert_js_args_to_python_args,
    date,
    datetime,
    file_type,
    none_type,
    validate_get_composed_info,
    OpenApiModel
)
from plaid.exceptions import ApiAttributeError


def lazy_import():
    from plaid.model.counterparty import Counterparty
    from plaid.model.location import Location
    from plaid.model.payment_channel import PaymentChannel
    from plaid.model.personal_finance_category import PersonalFinanceCategory
    from plaid.model.recurrence import Recurrence
    globals()['Counterparty'] = Counterparty
    globals()['Location'] = Location
    globals()['PaymentChannel'] = PaymentChannel
    globals()['PersonalFinanceCategory'] = PersonalFinanceCategory
    globals()['Recurrence'] = Recurrence


class Enrichments(ModelNormal):
    """NOTE: This class is auto generated by OpenAPI Generator.
    Ref: https://openapi-generator.tech

    Do not edit the class manually.

    Attributes:
      allowed_values (dict): The key is the tuple path to the attribute
          and the for var_name this is (var_name,). The value is a dict
          with a capitalized key describing the allowed value and an allowed
          value. These dicts store the allowed enum values.
      attribute_map (dict): The key is attribute name
          and the value is json key in definition.
      discriminator_value_class_map (dict): A dict to go from the discriminator
          variable value to the discriminator class name.
      validations (dict): The key is the tuple path to the attribute
          and the for var_name this is (var_name,). The value is a dict
          that stores validations for max_length, min_length, max_items,
          min_items, exclusive_maximum, inclusive_maximum, exclusive_minimum,
          inclusive_minimum, and regex.
      additional_properties_type (tuple): A tuple of classes accepted
          as additional properties values.
    """

    allowed_values = {
    }

    validations = {
    }

    @cached_property
    def additional_properties_type():
        """
        This must be a method because a model may have properties that are
        of type self, this must run after the class is loaded
        """
        lazy_import()
        return (bool, date, datetime, dict, float, int, list, str, none_type,)  # noqa: E501

    _nullable = False

    @cached_property
    def openapi_types():
        """
        This must be a method because a model may have properties that are
        of type self, this must run after the class is loaded

        Returns
            openapi_types (dict): The key is attribute name
                and the value is attribute type.
        """
        lazy_import()
        return {
            'counterparties': ([Counterparty],),  # noqa: E501
            'location': (Location,),  # noqa: E501
            'logo_url': (str, none_type,),  # noqa: E501
            'merchant_name': (str, none_type,),  # noqa: E501
            'payment_channel': (PaymentChannel,),  # noqa: E501
            'phone_number': (str, none_type,),  # noqa: E501
            'personal_finance_category': (PersonalFinanceCategory,),  # noqa: E501
            'personal_finance_category_icon_url': (str,),  # noqa: E501
            'website': (str, none_type,),  # noqa: E501
            'check_number': (str, none_type,),  # noqa: E501
            'entity_id': (str, none_type,),  # noqa: E501
            'legacy_category_id': (str, none_type,),  # noqa: E501
            'legacy_category': ([str],),  # noqa: E501
            'recurrence': (Recurrence,),  # noqa: E501
        }

    @cached_property
    def discriminator():
        return None


    attribute_map = {
        'counterparties': 'counterparties',  # noqa: E501
        'location': 'location',  # noqa: E501
        'logo_url': 'logo_url',  # noqa: E501
        'merchant_name': 'merchant_name',  # noqa: E501
        'payment_channel': 'payment_channel',  # noqa: E501
        'phone_number': 'phone_number',  # noqa: E501
        'personal_finance_category': 'personal_finance_category',  # noqa: E501
        'personal_finance_category_icon_url': 'personal_finance_category_icon_url',  # noqa: E501
        'website': 'website',  # noqa: E501
        'check_number': 'check_number',  # noqa: E501
        'entity_id': 'entity_id',  # noqa: E501
        'legacy_category_id': 'legacy_category_id',  # noqa: E501
        'legacy_category': 'legacy_category',  # noqa: E501
        'recurrence': 'recurrence',  # noqa: E501
    }

    read_only_vars = {
    }

    _composed_schemas = {}

    @classmethod
    @convert_js_args_to_python_args
    def _from_openapi_data(cls, counterparties, location, logo_url, merchant_name, payment_channel, phone_number, personal_finance_category, personal_finance_category_icon_url, website, *args, **kwargs):  # noqa: E501
        """Enrichments - a model defined in OpenAPI

        Args:
            counterparties ([Counterparty]): The counterparties present in the transaction. Counterparties, such as the merchant or the financial institution, are extracted by Plaid from the raw description.
            location (Location):
            logo_url (str, none_type): The URL of a logo associated with this transaction, if available. The logo will always be 100×100 pixel PNG file.
            merchant_name (str, none_type): The name of the primary counterparty, such as the merchant or the financial institution, as extracted by Plaid from the raw description.
            payment_channel (PaymentChannel):
            phone_number (str, none_type): The phone number associated with the counterparty in E. 164 format. If there is a location match (i.e. a street address is returned in the location object), the phone number will be location specific.
            personal_finance_category (PersonalFinanceCategory):
            personal_finance_category_icon_url (str): The URL of an icon associated with the primary personal finance category. The icon will always be 100×100 pixel PNG file.
            website (str, none_type): The website associated with this transaction.

        Keyword Args:
            _check_type (bool): if True, values for parameters in openapi_types
                                will be type checked and a TypeError will be
                                raised if the wrong type is input.
                                Defaults to True
            _path_to_item (tuple/list): This is a list of keys or values to
                                drill down to the model in received_data
                                when deserializing a response
            _spec_property_naming (bool): True if the variable names in the input data
                                are serialized names, as specified in the OpenAPI document.
                                False if the variable names in the input data
                                are pythonic names, e.g. snake case (default)
            _configuration (Configuration): the instance to use when
                                deserializing a file_type parameter.
                                If passed, type conversion is attempted
                                If omitted no type conversion is done.
            _visited_composed_classes (tuple): This stores a tuple of
                                classes that we have traveled through so that
                                if we see that class again we will not use its
                                discriminator again.
                                When traveling through a discriminator, the
                                composed schema that is
                                is traveled through is added to this set.
                                For example if Animal has a discriminator
                                petType and we pass in "Dog", and the class Dog
                                allOf includes Animal, we move through Animal
                                once using the discriminator, and pick Dog.
                                Then in Dog, we will make an instance of the
                                Animal class but this time we won't travel
                                through its discriminator because we passed in
                                _visited_composed_classes = (Animal,)
            check_number (str, none_type): The check number of the transaction. This field is only populated for check transactions.. [optional]  # noqa: E501
            entity_id (str, none_type): A unique, stable, Plaid-generated ID that maps to the primary counterparty.. [optional]  # noqa: E501
            legacy_category_id (str, none_type): The ID of the legacy category to which this transaction belongs. For a full list of legacy categories, see [`/categories/get`](https://plaid.com/docs/api/products/transactions/#categoriesget).  We recommend using the `personal_finance_category` for transaction categorization to obtain the best results.. [optional]  # noqa: E501
            legacy_category ([str]): A hierarchical array of the legacy categories to which this transaction belongs. For a full list of legacy categories, see [`/categories/get`](https://plaid.com/docs/api/products/transactions/#categoriesget).  We recommend using the `personal_finance_category` for transaction categorization to obtain the best results.. [optional]  # noqa: E501
            recurrence (Recurrence): [optional]  # noqa: E501
        """

        _check_type = kwargs.pop('_check_type', True)
        _spec_property_naming = kwargs.pop('_spec_property_naming', False)
        _path_to_item = kwargs.pop('_path_to_item', ())
        _configuration = kwargs.pop('_configuration', None)
        _visited_composed_classes = kwargs.pop('_visited_composed_classes', ())

        self = super(OpenApiModel, cls).__new__(cls)

        if args:
            for arg in args:
                if isinstance(arg, dict):
                    kwargs.update(arg)
                else:
                    raise ApiTypeError(
                        "Invalid positional arguments=%s passed to %s. Remove those invalid positional arguments." % (
                            args,
                            self.__class__.__name__,
                        ),
                        path_to_item=_path_to_item,
                        valid_classes=(self.__class__,),
                    )

        self._data_store = {}
        self._check_type = _check_type
        self._spec_property_naming = _spec_property_naming
        self._path_to_item = _path_to_item
        self._configuration = _configuration
        self._visited_composed_classes = _visited_composed_classes + (self.__class__,)

        self.counterparties = counterparties
        self.location = location
        self.logo_url = logo_url
        self.merchant_name = merchant_name
        self.payment_channel = payment_channel
        self.phone_number = phone_number
        self.personal_finance_category = personal_finance_category
        self.personal_finance_category_icon_url = personal_finance_category_icon_url
        self.website = website
        for var_name, var_value in kwargs.items():
            if var_name not in self.attribute_map and \
                        self._configuration is not None and \
                        self._configuration.discard_unknown_keys and \
                        self.additional_properties_type is None:
                # discard variable.
                continue
            setattr(self, var_name, var_value)
        return self

    required_properties = set([
        '_data_store',
        '_check_type',
        '_spec_property_naming',
        '_path_to_item',
        '_configuration',
        '_visited_composed_classes',
    ])

    @convert_js_args_to_python_args
    def __init__(self, counterparties, location, logo_url, merchant_name, payment_channel, phone_number, personal_finance_category, personal_finance_category_icon_url, website, *args, **kwargs):  # noqa: E501
        """Enrichments - a model defined in OpenAPI

        Args:
            counterparties ([Counterparty]): The counterparties present in the transaction. Counterparties, such as the merchant or the financial institution, are extracted by Plaid from the raw description.
            location (Location):
            logo_url (str, none_type): The URL of a logo associated with this transaction, if available. The logo will always be 100×100 pixel PNG file.
            merchant_name (str, none_type): The name of the primary counterparty, such as the merchant or the financial institution, as extracted by Plaid from the raw description.
            payment_channel (PaymentChannel):
            phone_number (str, none_type): The phone number associated with the counterparty in E. 164 format. If there is a location match (i.e. a street address is returned in the location object), the phone number will be location specific.
            personal_finance_category (PersonalFinanceCategory):
            personal_finance_category_icon_url (str): The URL of an icon associated with the primary personal finance category. The icon will always be 100×100 pixel PNG file.
            website (str, none_type): The website associated with this transaction.

        Keyword Args:
            _check_type (bool): if True, values for parameters in openapi_types
                                will be type checked and a TypeError will be
                                raised if the wrong type is input.
                                Defaults to True
            _path_to_item (tuple/list): This is a list of keys or values to
                                drill down to the model in received_data
                                when deserializing a response
            _spec_property_naming (bool): True if the variable names in the input data
                                are serialized names, as specified in the OpenAPI document.
                                False if the variable names in the input data
                                are pythonic names, e.g. snake case (default)
            _configuration (Configuration): the instance to use when
                                deserializing a file_type parameter.
                                If passed, type conversion is attempted
                                If omitted no type conversion is done.
            _visited_composed_classes (tuple): This stores a tuple of
                                classes that we have traveled through so that
                                if we see that class again we will not use its
                                discriminator again.
                                When traveling through a discriminator, the
                                composed schema that is
                                is traveled through is added to this set.
                                For example if Animal has a discriminator
                                petType and we pass in "Dog", and the class Dog
                                allOf includes Animal, we move through Animal
                                once using the discriminator, and pick Dog.
                                Then in Dog, we will make an instance of the
                                Animal class but this time we won't travel
                                through its discriminator because we passed in
                                _visited_composed_classes = (Animal,)
            check_number (str, none_type): The check number of the transaction. This field is only populated for check transactions.. [optional]  # noqa: E501
            entity_id (str, none_type): A unique, stable, Plaid-generated ID that maps to the primary counterparty.. [optional]  # noqa: E501
            legacy_category_id (str, none_type): The ID of the legacy category to which this transaction belongs. For a full list of legacy categories, see [`/categories/get`](https://plaid.com/docs/api/products/transactions/#categoriesget).  We recommend using the `personal_finance_category` for transaction categorization to obtain the best results.. [optional]  # noqa: E501
            legacy_category ([str]): A hierarchical array of the legacy categories to which this transaction belongs. For a full list of legacy categories, see [`/categories/get`](https://plaid.com/docs/api/products/transactions/#categoriesget).  We recommend using the `personal_finance_category` for transaction categorization to obtain the best results.. [optional]  # noqa: E501
            recurrence (Recurrence): [optional]  # noqa: E501
        """

        _check_type = kwargs.pop('_check_type', True)
        _spec_property_naming = kwargs.pop('_spec_property_naming', False)
        _path_to_item = kwargs.pop('_path_to_item', ())
        _configuration = kwargs.pop('_configuration', None)
        _visited_composed_classes = kwargs.pop('_visited_composed_classes', ())

        if args:
            for arg in args:
                if isinstance(arg, dict):
                    kwargs.update(arg)
                else:
                    raise ApiTypeError(
                        "Invalid positional arguments=%s passed to %s. Remove those invalid positional arguments." % (
                            args,
                            self.__class__.__name__,
                        ),
                        path_to_item=_path_to_item,
                        valid_classes=(self.__class__,),
                    )

        self._data_store = {}
        self._check_type = _check_type
        self._spec_property_naming = _spec_property_naming
        self._path_to_item = _path_to_item
        self._configuration = _configuration
        self._visited_composed_classes = _visited_composed_classes + (self.__class__,)

        self.counterparties = counterparties
        self.location = location
        self.logo_url = logo_url
        self.merchant_name = merchant_name
        self.payment_channel = payment_channel
        self.phone_number = phone_number
        self.personal_finance_category = personal_finance_category
        self.personal_finance_category_icon_url = personal_finance_category_icon_url
        self.website = website
        for var_name, var_value in kwargs.items():
            if var_name not in self.attribute_map and \
                        self._configuration is not None and \
                        self._configuration.discard_unknown_keys and \
                        self.additional_properties_type is None:
                # discard variable.
                continue
            setattr(self, var_name, var_value)
            if var_name in self.read_only_vars:
                raise ApiAttributeError(f"`{var_name}` is a read-only attribute. Use `from_openapi_data` to instantiate "
                                     f"class with read only attributes.")
