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



class PrismCashScoreMetadata(ModelNormal):
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
        return {
            'max_age': (int, none_type,),  # noqa: E501
            'min_age': (int, none_type,),  # noqa: E501
            'min_age_credit': (int, none_type,),  # noqa: E501
            'min_age_debit': (int, none_type,),  # noqa: E501
            'max_age_debit': (int, none_type,),  # noqa: E501
            'max_age_credit': (int, none_type,),  # noqa: E501
            'num_trxn_credit': (int, none_type,),  # noqa: E501
            'num_trxn_debit': (int, none_type,),  # noqa: E501
            'l1m_credit_value_cnt': (int, none_type,),  # noqa: E501
            'l1m_debit_value_cnt': (int, none_type,),  # noqa: E501
        }

    @cached_property
    def discriminator():
        return None


    attribute_map = {
        'max_age': 'max_age',  # noqa: E501
        'min_age': 'min_age',  # noqa: E501
        'min_age_credit': 'min_age_credit',  # noqa: E501
        'min_age_debit': 'min_age_debit',  # noqa: E501
        'max_age_debit': 'max_age_debit',  # noqa: E501
        'max_age_credit': 'max_age_credit',  # noqa: E501
        'num_trxn_credit': 'num_trxn_credit',  # noqa: E501
        'num_trxn_debit': 'num_trxn_debit',  # noqa: E501
        'l1m_credit_value_cnt': 'l1m_credit_value_cnt',  # noqa: E501
        'l1m_debit_value_cnt': 'l1m_debit_value_cnt',  # noqa: E501
    }

    read_only_vars = {
    }

    _composed_schemas = {}

    @classmethod
    @convert_js_args_to_python_args
    def _from_openapi_data(cls, max_age, min_age, min_age_credit, min_age_debit, max_age_debit, max_age_credit, num_trxn_credit, num_trxn_debit, l1m_credit_value_cnt, l1m_debit_value_cnt, *args, **kwargs):  # noqa: E501
        """PrismCashScoreMetadata - a model defined in OpenAPI

        Args:
            max_age (int, none_type): Number of days since the oldest transaction.
            min_age (int, none_type): Number of days since the latest transaction.
            min_age_credit (int, none_type): Number of days since the latest credit transaction.
            min_age_debit (int, none_type): Number of days since the latest debit transaction.
            max_age_debit (int, none_type): Number of days since the oldest debit transaction.
            max_age_credit (int, none_type): Number of days since the oldest credit transaction.
            num_trxn_credit (int, none_type): Number of credit transactions.
            num_trxn_debit (int, none_type): Number of debit transactions.
            l1m_credit_value_cnt (int, none_type): Number of credit transactions in the last 30 days.
            l1m_debit_value_cnt (int, none_type): Number of debit transactions in the last 30 days.

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

        self.max_age = max_age
        self.min_age = min_age
        self.min_age_credit = min_age_credit
        self.min_age_debit = min_age_debit
        self.max_age_debit = max_age_debit
        self.max_age_credit = max_age_credit
        self.num_trxn_credit = num_trxn_credit
        self.num_trxn_debit = num_trxn_debit
        self.l1m_credit_value_cnt = l1m_credit_value_cnt
        self.l1m_debit_value_cnt = l1m_debit_value_cnt
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
    def __init__(self, max_age, min_age, min_age_credit, min_age_debit, max_age_debit, max_age_credit, num_trxn_credit, num_trxn_debit, l1m_credit_value_cnt, l1m_debit_value_cnt, *args, **kwargs):  # noqa: E501
        """PrismCashScoreMetadata - a model defined in OpenAPI

        Args:
            max_age (int, none_type): Number of days since the oldest transaction.
            min_age (int, none_type): Number of days since the latest transaction.
            min_age_credit (int, none_type): Number of days since the latest credit transaction.
            min_age_debit (int, none_type): Number of days since the latest debit transaction.
            max_age_debit (int, none_type): Number of days since the oldest debit transaction.
            max_age_credit (int, none_type): Number of days since the oldest credit transaction.
            num_trxn_credit (int, none_type): Number of credit transactions.
            num_trxn_debit (int, none_type): Number of debit transactions.
            l1m_credit_value_cnt (int, none_type): Number of credit transactions in the last 30 days.
            l1m_debit_value_cnt (int, none_type): Number of debit transactions in the last 30 days.

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

        self.max_age = max_age
        self.min_age = min_age
        self.min_age_credit = min_age_credit
        self.min_age_debit = min_age_debit
        self.max_age_debit = max_age_debit
        self.max_age_credit = max_age_credit
        self.num_trxn_credit = num_trxn_credit
        self.num_trxn_debit = num_trxn_debit
        self.l1m_credit_value_cnt = l1m_credit_value_cnt
        self.l1m_debit_value_cnt = l1m_debit_value_cnt
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
